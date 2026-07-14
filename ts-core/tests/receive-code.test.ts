import { buildReceiveCode } from '../src/receive-code.js';

describe('buildReceiveCode', () => {
  it('builds the correct receive code format', () => {
    const result = buildReceiveCode('220311', '100', 'PREPAY123', '120m');
    expect(result).toBe('TELEBIRR$BUYGOODS220311100PREPAY123%120m');
  });

  it('handles numeric amount', () => {
    const result = buildReceiveCode('220311', 200, 'PREPAY456', '30m');
    expect(result).toBe('TELEBIRR$BUYGOODS220311200PREPAY456%30m');
  });

  it('handles empty short code', () => {
    const result = buildReceiveCode('', '100', 'PREPAY', '120m');
    expect(result).toBe('TELEBIRR$BUYGOODS100PREPAY%120m');
  });
});
