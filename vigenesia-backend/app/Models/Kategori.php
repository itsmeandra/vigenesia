<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kategori extends Model
{
    use HasFactory;

    protected $table = 'kategoris';
    protected $fillable = ['nama_kategori'];

    // Relasi: Satu Kategori memiliki banyak Motivasi
    public function motivasis()
    {
        return $this->hasMany(Motivasi::class);
    }
}
