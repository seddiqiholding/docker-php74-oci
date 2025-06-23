<?php
if (!function_exists('imagejpeg')) {
    echo "❌ GD imagejpeg() function is not available.\n";
} else {
    echo "✅ imagejpeg() is available.\n";
}

// phpinfo(); // Optional for full check
?>
