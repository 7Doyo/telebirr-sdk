<?php

declare(strict_types=1);

use App\Http\Controllers\PaymentController;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => view('welcome'));

Route::post('/charge', [PaymentController::class, 'charge']);
Route::post('/query', [PaymentController::class, 'query']);
Route::post('/refund', [PaymentController::class, 'refund']);
Route::post('/webhook', [PaymentController::class, 'webhook']);
Route::get('/receive-code/{prepayId}', [PaymentController::class, 'receiveCode']);
