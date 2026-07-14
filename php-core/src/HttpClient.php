<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core;

use Telebirr\Sdk\Core\Exceptions\NetworkException;

/**
 * HTTP client for making JSON API requests to the Telebirr gateway.
 *
 * Uses PHP cURL under the hood with SSL verification, 30-second timeout,
 * and automatic redirect following.
 */
class HttpClient
{
    /**
     * Send a JSON POST request to the specified URL.
     *
     * Encodes the body as JSON, sends it with the given headers, and returns
     * the decoded JSON response as an associative array.
     *
     * @param string $url The full URL to send the request to
     * @param array<mixed> $body The request body to be JSON-encoded
     * @param list<string> $headers Optional HTTP headers in "Name: Value" format
     *
     * @return array<mixed> The decoded JSON response as an associative array
     *
     * @throws NetworkException If the cURL request fails, returns a non-2xx status code, or the response is not valid JSON
     * @throws \JsonException If JSON encoding the request body or decoding the response fails
     */
    public static function postJson(string $url, array $body, array $headers = []): array
    {
        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_POST => true,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTPHEADER => array_merge([
                'Content-Type: application/json',
            ], $headers),
            CURLOPT_POSTFIELDS => json_encode($body, JSON_THROW_ON_ERROR),
            CURLOPT_TIMEOUT => 30,
            CURLOPT_SSL_VERIFYPEER => true,
            CURLOPT_SSL_VERIFYHOST => 2,
        ]);

        $response = curl_exec($ch);
        if ($response === false) {
            $error = curl_error($ch);
            curl_close($ch);
            throw new NetworkException('HTTP request failed: ' . $error);
        }

        $statusCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($statusCode < 200 || $statusCode >= 300) {
            throw new NetworkException("HTTP {$statusCode}: {$response}");
        }

        $decoded = json_decode($response, true, 512, JSON_THROW_ON_ERROR);
        if (!is_array($decoded)) {
            throw new NetworkException('Invalid JSON response');
        }

        return $decoded;
    }
}
