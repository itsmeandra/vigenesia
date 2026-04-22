<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Motivasi extends Model
{
    use HasFactory;

    protected $table = 'motivasis';

    protected $fillable = [
        'isi_motivasi',
        'user_id',
        'kategori_id',
    ];

    // Relasi: Motivasi dimiliki oleh satu User
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relasi: Motivasi memiliki satu Kategori
    public function kategori()
    {
        return $this->belongsTo(Kategori::class);
    }
}
