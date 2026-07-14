<?php

declare(strict_types=1);

require __DIR__ . '/../vendor/autoload.php';

use App\Dependencies;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;

$app = AppFactory::create();

Dependencies::register($app);

$app->post('/charge', function (Request $request, Response $response): Response {
    $data = (array) $request->getParsedBody();

    $amount = $data['amount'] ?? '';
    $title = $data['title'] ?? '';

    if ($amount === '' || $title === '') {
        $response->getBody()->write(json_encode(['error' => 'amount and title are required']));
        return $response->withStatus(400)->withHeader('Content-Type', 'application/json');
    }

    try {
        $sdk = telebirr();
        $result = $sdk->payments->charge(new \Telebirr\Sdk\Core\Models\CreateOrderParams(
            orderId: $data['orderId'] ?? uniqid('tlb_', true),
            amount: (string) $amount,
            title: $title,
            redirectUrl: $data['redirectUrl'] ?? null,
        ));

        $response->getBody()->write(json_encode([
            'success' => true,
            'prepayId' => $result->prepayId,
            'receiveCode' => $result->receiveCode,
            'message' => $result->message,
        ]));
        return $response->withHeader('Content-Type', 'application/json');
    } catch (\Throwable $e) {
        $response->getBody()->write(json_encode(['error' => $e->getMessage()]));
        return $response->withStatus(500)->withHeader('Content-Type', 'application/json');
    }
});

$app->post('/query', function (Request $request, Response $response): Response {
    $data = (array) $request->getParsedBody();
    $orderId = $data['orderId'] ?? '';

    if ($orderId === '') {
        $response->getBody()->write(json_encode(['error' => 'orderId is required']));
        return $response->withStatus(400)->withHeader('Content-Type', 'application/json');
    }

    try {
        $sdk = telebirr();
        $result = $sdk->payments->query(new \Telebirr\Sdk\Core\Models\QueryOrderParams(
            merchOrderId: $orderId,
        ));

        $response->getBody()->write(json_encode([
            'success' => true,
            'status' => $result->status->value,
            'isTerminal' => $result->status->isTerminal(),
        ]));
        return $response->withHeader('Content-Type', 'application/json');
    } catch (\Throwable $e) {
        $response->getBody()->write(json_encode(['error' => $e->getMessage()]));
        return $response->withStatus(500)->withHeader('Content-Type', 'application/json');
    }
});

$app->post('/refund', function (Request $request, Response $response): Response {
    $data = (array) $request->getParsedBody();

    $orderId = $data['orderId'] ?? '';
    $refundRequestNo = $data['refundRequestNo'] ?? '';
    $refundAmount = $data['refundAmount'] ?? '';

    if ($orderId === '' || $refundRequestNo === '' || $refundAmount === '') {
        $response->getBody()->write(json_encode([
            'error' => 'orderId, refundRequestNo, and refundAmount are required',
        ]));
        return $response->withStatus(400)->withHeader('Content-Type', 'application/json');
    }

    try {
        $sdk = telebirr();
        $result = $sdk->payments->refund(new \Telebirr\Sdk\Core\Models\RefundParams(
            merchOrderId: $orderId,
            refundRequestNo: $refundRequestNo,
            refundAmount: (string) $refundAmount,
            refundReason: $data['refundReason'] ?? null,
        ));

        $response->getBody()->write(json_encode([
            'success' => true,
            'refundOrderId' => $result->refundOrderId,
            'refundStatus' => $result->refundStatus,
            'message' => $result->message,
        ]));
        return $response->withHeader('Content-Type', 'application/json');
    } catch (\Throwable $e) {
        $response->getBody()->write(json_encode(['error' => $e->getMessage()]));
        return $response->withStatus(500)->withHeader('Content-Type', 'application/json');
    }
});

$app->post('/webhook', function (Request $request, Response $response): Response {
    $payload = (array) $request->getParsedBody();
    $publicKey = $_ENV['TELEBIRR_PUBLIC_KEY'] ?? '';

    if ($publicKey === '') {
        $response->getBody()->write(json_encode(['error' => 'Public key not configured']));
        return $response->withStatus(500)->withHeader('Content-Type', 'application/json');
    }

    $verified = \Telebirr\Sdk\Core\Webhook::verify($payload, $publicKey);

    if (!$verified) {
        $response->getBody()->write(json_encode(['error' => 'Invalid signature']));
        return $response->withStatus(401)->withHeader('Content-Type', 'application/json');
    }

    error_log(sprintf(
        'Webhook: order=%s status=%s amount=%s',
        $payload['merch_order_id'] ?? 'unknown',
        $payload['trade_status'] ?? 'unknown',
        $payload['total_amount'] ?? '0',
    ));

    $response->getBody()->write(json_encode(['status' => 'ok']));
    return $response->withHeader('Content-Type', 'application/json');
});

$app->get('/receive-code/{prepayId}', function (Request $request, Response $response, array $args): Response {
    $prepayId = $args['prepayId'] ?? '';

    if ($prepayId === '') {
        $response->getBody()->write(json_encode(['error' => 'prepayId is required']));
        return $response->withStatus(400)->withHeader('Content-Type', 'application/json');
    }

    $config = config('telebirr');
    $receiveCode = \Telebirr\Sdk\Core\ReceiveCode::build(
        shortCode: $config['short_code'] ?? '220311',
        amount: '0',
        prepayId: $prepayId,
        timeout: $config['timeout'] ?? '120m',
    );

    $response->getBody()->write(json_encode(['receiveCode' => $receiveCode]));
    return $response->withHeader('Content-Type', 'application/json');
});

$app->run();
