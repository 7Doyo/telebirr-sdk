import { randomBytes } from 'node:crypto';
import type { TelebirrConfig, Environment } from './models/config.js';
import type {
  CreateOrderParams,
  CreateOrderResponse,
  TradeType,
} from './models/create-order.js';
import {
  mapTelebirrStatus,
  type QueryOrderParams,
  type QueryOrderResponse,
} from './models/query-order.js';
import type { RefundParams, RefundResponse } from './models/refund.js';
import { signRequest } from './signing.js';
import { postJson } from './http.js';
import { ValidationError, EnvironmentError, TelebirrError } from './exceptions.js';
import { buildReceiveCode } from './receive-code.js';
import { TokenCache } from './token-cache.js';

/** Default base URLs keyed by environment. */
const BASE_URLS: Record<Environment, string> = {
  SANDBOX: 'https://developerportal.ethiotelebirr.et:38443/apiaccess/payment/gateway',
  PRODUCTION:
    'https://telebirrappcube.ethiomobilemoney.et:38443/apiaccess/payment/gateway',
};

/** Raw response shape from the Telebirr token endpoint. */
interface TokenResponse {
  /** Response code (`'0'` = success). */
  code: string;
  /** Fabric token string. */
  token?: string;
  /** Token effective date (ISO 8601). */
  effectiveDate?: string;
  /** Token expiration date (ISO 8601). */
  expirationDate?: string;
  /** Human-readable message. */
  message?: string;
}

/** Raw response shape from the Telebirr create-order endpoint. */
interface CreateOrderApiResponse {
  /** Response code (`'0'` = success). */
  code: string;
  /** Human-readable message. */
  message?: string;
  /** Business-level response content. */
  biz_content?: {
    /** Prepay ID for the newly created order. */
    prepay_id?: string;
    /** Business-level code. */
    code?: string;
    /** Business-level message. */
    message?: string;
  };
}

/** Raw response shape from the Telebirr query-order endpoint. */
interface QueryOrderApiResponse {
  /** Response code (`'0'` = success). */
  code: string;
  /** Human-readable message. */
  message?: string;
  /** Business-level response content. */
  biz_content?: {
    /** Raw trade status string from Telebirr. */
    trade_status?: string;
    /** Business-level code. */
    code?: string;
    /** Business-level message. */
    message?: string;
  };
}

/** Raw response shape from the Telebirr refund endpoint. */
interface RefundApiResponse {
  /** Response code (`'0'` = success). */
  code: string;
  /** Human-readable message. */
  message?: string;
  /** Business-level response content. */
  biz_content?: {
    /** Telebirr-assigned refund order ID. */
    refund_order_id?: string;
    /** Refund status string. */
    refund_status?: string;
    /** Business-level code. */
    code?: string;
    /** Business-level message. */
    message?: string;
  };
}

/**
 * Entry point for the Telebirr SDK.
 *
 * Validates configuration on construction and exposes a {@link Payments}
 * instance for all payment operations.
 *
 * @example
 * ```ts
 * const telebirr = new Telebirr({
 *   environment: 'SANDBOX',
 *   fabricAppId: '5f0b1a2c-...',
 *   merchantAppId: '12345',
 *   merchantCode: 'TEST_MERCHANT',
 *   appSecret: 'sk_test_xxx',
 *   privateKeyPem: '-----BEGIN PRIVATE KEY-----\n...',
 *   shortCode: '220311',
 *   timeout: '120m',
 *   notifyUrl: 'https://example.com/webhook',
 * });
 *
 * const result = await telebirr.payments.charge({ amount: '100', title: 'Coffee' });
 * ```
 */
export class Telebirr {
  /** The payments interface for creating, querying, and refunding orders. */
  readonly payments: Payments;

  /**
   * Creates a new Telebirr SDK instance.
   *
   * @param config - SDK configuration including credentials and environment.
   * @throws {EnvironmentError} If the key type does not match the environment.
   */
  constructor(config: TelebirrConfig) {
    this.validateConfig(config);
    this.payments = new Payments(config);
  }

  /**
   * Validates that the key prefix matches the selected environment.
   *
   * @param config - The SDK configuration to validate.
   * @throws {EnvironmentError} If a test key is used with production or vice versa.
   */
  private validateConfig(config: TelebirrConfig): void {
    const key = config.fabricAppId;

    if (config.environment === 'PRODUCTION' && key.startsWith('sk_test_')) {
      throw new EnvironmentError(
        'Test key cannot be used with PRODUCTION environment',
      );
    }

    if (config.environment === 'SANDBOX' && key.startsWith('sk_live_')) {
      throw new EnvironmentError(
        'Live key cannot be used with SANDBOX environment',
      );
    }
  }
}

/**
 * Provides methods for all Telebirr payment operations:
 * charge, query, refund, and receive-code generation.
 *
 * Manages token caching internally — callers never need to handle tokens directly.
 *
 * @example
 * ```ts
 * const result = await payments.charge({ amount: '50', title: 'Lunch' });
 * const status = await payments.query({ merchOrderId: 'ORD1719000000ABC' });
 * ```
 */
export class Payments {
  private readonly config: TelebirrConfig;
  private readonly baseUrl: string;
  private readonly tokenCache: TokenCache;

  /**
   * @param config - Full SDK configuration.
   */
  constructor(config: TelebirrConfig) {
    this.config = config;
    this.baseUrl = config.baseUrl ?? BASE_URLS[config.environment];
    this.tokenCache = new TokenCache({ ttlMs: 50 * 60 * 1000 });
  }

  /**
   * Creates a new payment order with Telebirr.
   *
   * Validates inputs, obtains a fabric token (with caching), signs the
   * request, and returns the prepay ID and receive code.
   *
   * @param params - Order parameters including amount and title.
   * @param tradeType - Payment flow type. Defaults to `'InApp'`.
   * @returns The create-order response with `prepayId` and `receiveCode`.
   * @throws {ValidationError} If `amount` is not positive or `title` is missing.
   * @throws {TelebirrError} If the API returns a non-zero code.
   *
   * @example
   * ```ts
   * const result = await payments.charge({
   *   amount: '250',
   *   title: 'Wireless Headphones',
   *   orderId: 'ORD1719000000ABC',
   * }, 'InApp');
   *
   * console.log(result.prepayId);   // "PREPAY..."
   * console.log(result.receiveCode); // "TELEBIRR$BUYGOODS..."
   * ```
   */
  async charge(
    params: CreateOrderParams,
    tradeType: TradeType = 'InApp',
  ): Promise<CreateOrderResponse> {
    if (!params.amount || Number(params.amount) <= 0) {
      throw new ValidationError('Amount must be a positive number');
    }
    if (!params.title) {
      throw new ValidationError('Title is required');
    }

    const orderId = params.orderId ?? this.generateOrderId();
    const token = await this.getToken();

    const bizContent: Record<string, unknown> = {
      notify_url: this.config.notifyUrl,
      business_type: 'BuyGoods',
      trade_type: tradeType,
      appid: this.config.merchantAppId,
      merch_code: this.config.merchantCode,
      merch_order_id: orderId,
      title: params.title,
      total_amount: params.amount,
      trans_currency: 'ETB',
      timeout_express: this.config.timeout,
      payee_identifier: this.config.shortCode,
      payee_identifier_type: '04',
      payee_type: '5000',
    };

    if (params.redirectUrl) {
      bizContent.redirect_url = params.redirectUrl;
    }
    if (params.callbackInfo) {
      bizContent.callback_info = params.callbackInfo;
    }

    const requestBody: Record<string, unknown> = {
      nonce_str: this.generateNonceStr(),
      method: 'payment.preorder',
      version: '1.0',
      sign_type: 'SHA256WithRSA',
      biz_content: bizContent,
    };

    requestBody.timestamp = String(Math.floor(Date.now() / 1000));

    const sign = signRequest(requestBody, this.config.privateKeyPem);
    requestBody.sign = sign;

    const url = `${this.baseUrl}/payment/v1/merchant/inapp/createOrder`;
    const raw = await postJson<CreateOrderApiResponse>(url, requestBody, {
      'X-APP-Key': this.config.fabricAppId,
      Authorization: token,
    });

    if (raw.code !== '0') {
      throw new TelebirrError(
        raw.message ?? raw.biz_content?.message ?? 'CreateOrder failed',
        raw.code,
      );
    }

    const prepayId = raw.biz_content?.prepay_id;
    if (!prepayId) {
      throw new TelebirrError('No prepay_id in response', raw.code);
    }

    const receiveCode = buildReceiveCode(
      this.config.shortCode,
      params.amount,
      prepayId,
      this.config.timeout,
    );

    return {
      code: raw.code,
      message: raw.message ?? raw.biz_content?.message,
      prepayId,
      receiveCode,
      rawResponse: raw as unknown as Record<string, unknown>,
    };
  }

  /**
   * Queries the status of an existing order.
   *
   * @param params - Query parameters containing the merchant order ID.
   * @returns The query response with a normalised {@link PaymentStatus}.
   * @throws {ValidationError} If `merchOrderId` is missing.
   * @throws {TelebirrError} If the API returns a non-zero code.
   *
   * @example
   * ```ts
   * const { status } = await payments.query({ merchOrderId: 'ORD1719000000ABC' });
   * if (status === PaymentStatus.SUCCESS) {
   *   console.log('Payment completed!');
   * }
   * ```
   */
  async query(params: QueryOrderParams): Promise<QueryOrderResponse> {
    if (!params.merchOrderId) {
      throw new ValidationError('merchOrderId is required');
    }

    const token = await this.getToken();

    const requestBody: Record<string, unknown> = {
      nonce_str: this.generateNonceStr(),
      method: 'payment.queryorder',
      version: '1.0',
      sign_type: 'SHA256WithRSA',
      biz_content: {
        appid: this.config.merchantAppId,
        merch_code: this.config.merchantCode,
        merch_order_id: params.merchOrderId,
      },
    };

    requestBody.timestamp = String(Math.floor(Date.now() / 1000));

    const sign = signRequest(requestBody, this.config.privateKeyPem);
    requestBody.sign = sign;

    const url = `${this.baseUrl}/payment/v1/merchant/queryOrder`;
    const raw = await postJson<QueryOrderApiResponse>(url, requestBody, {
      'X-APP-Key': this.config.fabricAppId,
      Authorization: token,
    });

    if (raw.code !== '0') {
      throw new TelebirrError(
        raw.message ?? raw.biz_content?.message ?? 'Query failed',
        raw.code,
      );
    }

    return {
      code: raw.code,
      status: mapTelebirrStatus(raw.biz_content?.trade_status ?? ''),
      rawResponse: raw as unknown as Record<string, unknown>,
    };
  }

  /**
   * Refunds an existing order (full or partial).
   *
   * @param params - Refund parameters including the original order ID,
   *   a unique refund request number, and the refund amount.
   * @returns The refund response with status and refund order ID.
   * @throws {ValidationError} If required fields are missing or the amount is invalid.
   * @throws {TelebirrError} If the API returns a non-zero code.
   *
   * @example
   * ```ts
   * const result = await payments.refund({
   *   merchOrderId: 'ORD1719000000ABC',
   *   refundRequestNo: 'RFD1719000001DEF',
   *   refundAmount: '50',
   *   refundReason: 'Customer request',
   * });
   * console.log(result.refundStatus); // "SUCCESS"
   * ```
   */
  async refund(params: RefundParams): Promise<RefundResponse> {
    if (!params.merchOrderId) {
      throw new ValidationError('merchOrderId is required');
    }
    if (!params.refundRequestNo) {
      throw new ValidationError('refundRequestNo is required');
    }
    if (!params.refundAmount || Number(params.refundAmount) <= 0) {
      throw new ValidationError('refundAmount must be a positive number');
    }

    const token = await this.getToken();

    const requestBody: Record<string, unknown> = {
      nonce_str: this.generateNonceStr(),
      method: 'payment.refund',
      version: '1.0',
      sign_type: 'SHA256WithRSA',
      biz_content: {
        appid: this.config.merchantAppId,
        merch_code: this.config.merchantCode,
        merch_order_id: params.merchOrderId,
        refund_request_no: params.refundRequestNo,
        refund_amount: params.refundAmount,
        refund_reason: params.refundReason,
      },
    };

    requestBody.timestamp = String(Math.floor(Date.now() / 1000));

    const sign = signRequest(requestBody, this.config.privateKeyPem);
    requestBody.sign = sign;

    const url = `${this.baseUrl}/payment/v1/merchant/refund`;
    const raw = await postJson<RefundApiResponse>(url, requestBody, {
      'X-APP-Key': this.config.fabricAppId,
      Authorization: token,
    });

    if (raw.code !== '0') {
      throw new TelebirrError(
        raw.message ?? raw.biz_content?.message ?? 'Refund failed',
        raw.code,
      );
    }

    return {
      code: raw.code,
      message: raw.message ?? raw.biz_content?.message,
      refundOrderId: raw.biz_content?.refund_order_id,
      refundStatus: raw.biz_content?.refund_status,
      rawResponse: raw as unknown as Record<string, unknown>,
    };
  }

  /**
   * Builds a receive code from a prepay ID using the configured short code and timeout.
   *
   * @param prepayId - Prepay ID from a create-order response.
   * @returns The formatted receive code string.
   *
   * @example
   * ```ts
   * const code = payments.buildReceiveCode('PREPAY123');
   * // "TELEBIRR$BUYGOODS2203110PREPAY123%120m"
   * ```
   */
  buildReceiveCode(prepayId: string): string {
    return buildReceiveCode(
      this.config.shortCode,
      '0',
      prepayId,
      this.config.timeout,
    );
  }

  /**
   * Obtains a fabric token, using the in-memory cache when available.
   *
   * @returns A valid fabric token string.
   * @throws {TelebirrError} If the token request fails.
   */
  private async getToken(): Promise<string> {
    const cached = this.tokenCache.get();
    if (cached) return cached;

    const url = `${this.baseUrl}/payment/v1/token`;
    const raw = await postJson<TokenResponse>(
      url,
      { appSecret: this.config.appSecret },
      { 'X-APP-Key': this.config.fabricAppId },
    );

    if (raw.code !== '0' || !raw.token) {
      throw new TelebirrError(
        raw.message ?? 'Failed to obtain token',
        raw.code,
      );
    }

    this.tokenCache.set(raw.token);
    return raw.token;
  }

  /**
   * Generates a unique order ID prefixed with `ORD` and the current timestamp.
   *
   * @returns A string like `"ORD1719000000A1B2C3D4"`.
   */
  private generateOrderId(): string {
    return `ORD${Date.now()}${randomBytes(4).toString('hex').toUpperCase()}`;
  }

  /**
   * Generates a 32-character uppercase hex nonce for API requests.
   *
   * @returns A 32-character uppercase alphanumeric string.
   */
  private generateNonceStr(): string {
    return randomBytes(16)
      .toString('hex')
      .toUpperCase()
      .slice(0, 32);
  }
}
