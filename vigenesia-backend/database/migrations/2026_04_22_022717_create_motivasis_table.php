<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('motivasis', function (Blueprint $table) {
            $table->id();
            $table->text('isi_motivasi');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('kategori_id')->nullable()->constrained('kategoris')->onDelete('set null');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('motivasis');
    }
};
