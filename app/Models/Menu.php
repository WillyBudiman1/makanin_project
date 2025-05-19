<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Menu extends Model
{
    use HasFactory;

    // Field yang bisa diisi secara mass-assignment
    protected $fillable = [
        'name',
        'description',
        'price',
        'image',
    ];
}
