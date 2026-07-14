<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core;

use Telebirr\Sdk\Core\Exceptions\SigningException;

/**
 * RSA-PSS request signing implementation for the Telebirr payment gateway.
 *
 * Handles building the canonical sign string and producing SHA256withRSA-PSS signatures
 * with a 32-byte salt length as required by the Telebirr API.
 */
class Signer
{
    /**
     * Field names to exclude from the signing string.
     *
     * @var list<string>
     */
    private const EXCLUDED_FIELDS = [
        'sign',
        'sign_type',
        'header',
        'refund_info',
        'openType',
        'raw_request',
        'biz_content',
    ];

    /**
     * PSS salt length in bytes.
     *
     * @var int
     */
    private const SALT_LENGTH = 32;

    /**
     * SHA-256 hash output length in bytes.
     *
     * @var int
     */
    private const HASH_LENGTH = 32;

    /**
     * Hash algorithm identifier.
     *
     * @var string
     */
    private const HASH_ALGO = 'sha256';

    /**
     * Sign a request array using SHA256withRSA-PSS.
     *
     * Builds the canonical sign string from the request fields, then produces
     * a PSS signature using the provided PEM-encoded private key.
     *
     * @param array<mixed> $request The request body to sign
     * @param string $privateKeyPem PEM-encoded RSA private key (PKCS#8)
     *
     * @return string Base64-encoded PSS signature
     *
     * @throws SigningException If the private key cannot be loaded or signing fails
     */
    public static function sign(array $request, string $privateKeyPem): string
    {
        $signString = self::buildSignString($request);

        return self::sha256PssSign($signString, $privateKeyPem);
    }

    /**
     * Build the canonical signing string from a request array.
     *
     * Flattens top-level and biz_content fields (excluding listed fields),
     * sorts all keys lexicographically, and joins as key=value pairs with '&'.
     *
     * @param array<mixed> $request The request body to build the sign string from
     *
     * @return string The canonical key=value&... signing string
     */
    public static function buildSignString(array $request): string
    {
        $fieldMap = [];
        $fields = [];

        foreach ($request as $key => $value) {
            if (in_array($key, self::EXCLUDED_FIELDS, true)) {
                continue;
            }
            $fields[] = $key;
            $fieldMap[$key] = (string) $value;
        }

        if (isset($request['biz_content']) && is_array($request['biz_content'])) {
            foreach ($request['biz_content'] as $key => $value) {
                if (in_array($key, self::EXCLUDED_FIELDS, true)) {
                    continue;
                }
                $fields[] = $key;
                $fieldMap[$key] = (string) $value;
            }
        }

        sort($fields, SORT_STRING);

        $parts = [];
        foreach ($fields as $field) {
            $parts[] = $field . '=' . $fieldMap[$field];
        }

        return implode('&', $parts);
    }

    /**
     * Perform SHA256withRSA-PSS signing on a data string.
     *
     * Hashes the data with SHA-256, applies EMSA-PSS encoding with a 32-byte random salt,
     * and encrypts with the RSA private key using no padding mode.
     *
     * @param string $data The string data to sign
     * @param string $privateKeyPem PEM-encoded RSA private key (PKCS#8)
     *
     * @return string Base64-encoded signature
     *
     * @throws SigningException If the private key cannot be loaded, details cannot be read, or encryption fails
     */
    private static function sha256PssSign(string $data, string $privateKeyPem): string
    {
        $key = openssl_pkey_get_private($privateKeyPem);
        if ($key === false) {
            throw new SigningException('Failed to load private key: ' . openssl_error_string());
        }

        $details = openssl_pkey_get_details($key);
        if ($details === false) {
            throw new SigningException('Failed to get key details');
        }

        $modulusLength = (int) ceil($details['bits'] / 8);

        $hash = hash(self::HASH_ALGO, $data, true);

        $salt = random_bytes(self::SALT_LENGTH);

        $em = self::pssEncode($hash, $modulusLength, $salt);

        $encrypted = '';
        $success = openssl_private_encrypt($em, $encrypted, $key, \OPENSSL_NO_PADDING);

        if (!$success) {
            throw new SigningException('Signing failed: ' . openssl_error_string());
        }

        return base64_encode($encrypted);
    }

    /**
     * Encode a message hash using EMSA-PSS encoding (PKCS#1 v2.1).
     *
     * Produces the encoded message (EM) for RSA-PSS signing by constructing the
     * padded database, applying MGF1 mask generation, and combining with the hash.
     *
     * @param string $mHash The SHA-256 hash of the message (raw binary, 32 bytes)
     * @param int $emLength Desired length of the encoded message in bytes
     * @param string $salt Random salt bytes (32 bytes)
     *
     * @return string The encoded message ready for RSA encryption
     *
     * @throws SigningException If the key is too short for the required PSS encoding
     */
    private static function pssEncode(string $mHash, int $emLength, string $salt): string
    {
        $sLen = strlen($salt);
        $hLen = self::HASH_LENGTH;

        if ($emLength < $hLen + $sLen + 2) {
            throw new SigningException('Key too short for PSS encoding');
        }

        $mPrime = str_repeat("\0", 8) . $mHash . $salt;
        $h = hash(self::HASH_ALGO, $mPrime, true);

        $psLength = $emLength - $sLen - $hLen - 2;
        $db = str_repeat("\0", $psLength) . "\x01" . $salt;

        $dbMask = self::mgf1($h, $emLength - $hLen - 1);
        $maskedDb = self::xorBytes($db, $dbMask);

        $maskedDb[0] = chr(ord($maskedDb[0]) & 0x7F);

        return $maskedDb . $h . "\xbc";
    }

    /**
     * MGF1 (Mask Generation Function 1) based on SHA-256.
     *
     * Generates a mask of the specified length from a seed using iterative SHA-256 hashing.
     *
     * @param string $seed The seed for mask generation (raw binary)
     * @param int $targetLength Desired output length in bytes
     *
     * @return string The generated mask of exactly targetLength bytes
     */
    private static function mgf1(string $seed, int $targetLength): string
    {
        $hLen = self::HASH_LENGTH;
        $count = (int) ceil($targetLength / $hLen);
        $output = '';

        for ($i = 0; $i < $count; $i++) {
            $counter = pack('N', $i);
            $output .= hash(self::HASH_ALGO, $seed . $counter, true);
        }

        return substr($output, 0, $targetLength);
    }

    /**
     * XOR two byte strings together.
     *
     * Produces a byte string where each byte is the XOR of the corresponding bytes
     * from inputs $a and $b. The result length equals the shorter input length.
     *
     * @param string $a First byte string
     * @param string $b Second byte string
     *
     * @return string XORed result byte string
     */
    private static function xorBytes(string $a, string $b): string
    {
        $len = min(strlen($a), strlen($b));
        $result = '';
        for ($i = 0; $i < $len; $i++) {
            $result .= chr(ord($a[$i]) ^ ord($b[$i]));
        }
        return $result;
    }
}
