<?php

namespace Tests\Feature;

use Tests\TestCase;

class ReadOnlyPreviewTest extends TestCase
{
    public function test_read_only_preview_disables_authentication_and_registration(): void
    {
        config([
            'app.read_only_preview' => true,
            'app.registration_enabled' => false,
        ]);

        $this->get('/connexion')
            ->assertOk()
            ->assertSee('Mode lecture seule')
            ->assertDontSee('90000001');

        $this->post('/connexion', [
            'telephone' => '90000001',
            'password' => 'password',
        ])->assertForbidden();

        $this->get('/inscription')->assertNotFound();
    }
}
