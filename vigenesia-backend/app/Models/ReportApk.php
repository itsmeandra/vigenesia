<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ReportApk extends Model
{
    use HasFactory;

    protected $table = 'report_apks';
    protected $fillable = ['deskripsi'];
}
