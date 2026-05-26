<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens; // Penting untuk API Login
use App\Models\Motivasi;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens ,HasFactory, Notifiable;

    protected $table = 'users';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'nama',
        'profesi',
        'email',
        'password',
        'role_id',
        'is_active',
        'bio',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
    ];

    // Relasi: User dimiliki oleh satu Role
    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    // Relasi: User memiliki banyak Motivasi
    public function motivasis()
    {
        return $this->hasMany(Motivasi::class);
    }

    // Relasi: User memiliki banyak likes
    public function likes() {
        return $this->belongsToMany(Motivasi::class, 'likes');
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
}
