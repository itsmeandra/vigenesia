<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class Motivasi extends Model
{
    use HasFactory;

    protected $table = 'motivasis';

    protected $fillable = [
        'isi_motivasi',
        'user_id',
        'kategori_id',
        'parent_id',
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

    public function likes() 
    {
        return $this->belongsToMany(User::class, 'likes');
    }

    public function parent() 
    {
        return $this->belongsTo(Motivasi::class, 'parent_id')->with('user');
    }

    public function reposts() {
        return $this->hasMany(Motivasi::class, 'parent_id');
    }
}
