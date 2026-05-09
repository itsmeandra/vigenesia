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
        Schema::table('motivasis', function (Blueprint $table) {
            // parent_id merujuk ke ID motivasi asli yang di-repost
            $table->foreignId('parent_id')->nullable()->constrained('motivasis')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('motivasis', function (Blueprint $table) {
            //
        });
    }
};
