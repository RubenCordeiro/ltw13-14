<?php
    require_once 'details\user_management.php';

    if (!isset($_SESSION)) {
        session_save_path(dirname($_SERVER['SCRIPT_FILENAME']) . '/../sessions');
        session_start();
    }
    session_destroy();

    redirect();
