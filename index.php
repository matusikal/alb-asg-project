<?php
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://169.254.169.254/latest/api/token");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
curl_setopt($ch, CURLOPT_HTTPHEADER, array("X-aws-ec2-metadata-token-ttl-seconds: 21600"));
$token = curl_exec($ch);
curl_close($ch);
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://169.254.169.254/latest/meta-data/instance-id");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, array("X-aws-ec2-metadata-token: $token"));
$instance_id = curl_exec($ch);
curl_close($ch);
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://169.254.169.254/latest/meta-data/local-ipv4");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, array("X-aws-ec2-metadata-token: $token"));
$local_ip = curl_exec($ch);
curl_close($ch);
if (isset($_POST['stress'])) {
    $already_running = shell_exec('pgrep -x stress');
    
    if (empty($already_running)) {
        shell_exec('stress --cpu $(nproc) --timeout 600 > /dev/null 2>&1 &');
        $message = "CPU Stress test initiated across all available cores! The site will be a bit slow, but it will remain alive while Auto Scaling boots up a new instance. Refresh in 2-3 minutes.";
    } else {
        $message = "A stress test is already running on this instance. No need to click again!";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AWS Auto Scaling & ELB Demo</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; background: #0f172a; color: #f8fafc; text-align: center; padding: 50px; }
        .container { display: flex; flex-direction: column; align-items: center; gap: 30px; max-width: 1000px; margin: 0 auto; }
        .card { background: #1e293b; padding: 40px; border-radius: 12px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.3); width: 100%; max-width: 500px; text-align: center; }
        h1 { color: #38bdf8; margin-bottom: 5px; }
        .ip-box { background: #334155; padding: 20px; border-radius: 8px; margin: 20px 0; font-size: 1.1em; text-align: left; line-height: 1.6; }
        .btn { background: #ef4444; color: white; border: none; padding: 14px 28px; font-size: 16px; border-radius: 6px; cursor: pointer; font-weight: bold; width: 100%; transition: 0.2s; }
        .btn:hover { background: #dc2626; transform: scale(1.02); }
        .alert { background: #1e3a8a; border: 1px solid #3b82f6; color: #93c5fd; padding: 15px; border-radius: 6px; margin-top: 20px; font-weight: 500; text-align: left; }
        code { background: #0f172a; padding: 2px 6px; border-radius: 4px; color: #f43f5e; font-family: monospace; }
        
        /* 📈 Custom Dashboard Layout Styles */
        .dashboard-panel { background: #1e293b; width: 100%; max-width: 1250px; border-radius: 12px; padding: 20px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.3); }
        .dashboard-title { color: #38bdf8; text-align: left; margin-bottom: 15px; font-size: 1.2rem; font-weight: bold; }
        iframe { width: 100%; height: 600px; border: none; border-radius: 8px; background: #111; }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1>AWS Scalability Demo</h1>
            <p style="color: #94a3b8;">Portfolio Infrastructure Project</p>
            <hr style="border-color: #334155;">
            <div class="ip-box">
                <strong>Active Instance ID:</strong> <code><?php echo htmlspecialchars(trim($instance_id)); ?></code><br>
                <strong>Private IP Address:</strong> <code><?php echo htmlspecialchars(trim($local_ip)); ?></code>
            </div>
            <form method="post">
                <button type="submit" name="stress" class="btn">Trigger CPU Stress Test</button>
            </form>
            <?php if (isset($message)) { echo "<div class='alert'>$message</div>"; } ?>
        </div>

    </div>
</body>
</html>