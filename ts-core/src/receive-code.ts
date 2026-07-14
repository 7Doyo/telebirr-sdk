/**
 * Builds a Telebirr receive code string for the mobile SDK payment flow.
 *
 * Format: `TELEBIRR$BUYGOODS{shortCode}{amount}{prepay_id}%{timeout}`
 *
 * @param shortCode - Merchant short code (e.g. `"220311"`).
 * @param amount - Payment amount in ETB.
 * @param prepayId - Prepay ID returned from the create-order response.
 * @param timeout - Payment timeout expression (e.g. `"120m"`).
 * @returns The formatted receive code string.
 *
 * @example
 * ```ts
 * buildReceiveCode('220311', '100', 'PREPAY123', '120m');
 * // "TELEBIRR$BUYGOODS220311100PREPAY123%120m"
 * ```
 */
export function buildReceiveCode(
  shortCode: string,
  amount: string | number,
  prepayId: string,
  timeout: string,
): string {
  return `TELEBIRR$BUYGOODS${shortCode}${amount}${prepayId}%${timeout}`;
}
