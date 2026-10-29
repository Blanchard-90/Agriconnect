<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ReadOnlyPreview
{
    public function handle(Request $request, Closure $next): Response
    {
        abort_if(
            config('app.read_only_preview') && ! $request->isMethodSafe(),
            403,
            'Cette prévisualisation est en lecture seule.'
        );

        return $next($request);
    }
}
