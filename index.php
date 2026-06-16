<?php

function getMetadata($path)
{
    static $token = null;

    if ($token === null) {
        $token = trim(shell_exec(
            "curl -s -X PUT http://169.254.169.254/latest/api/token " .
            "-H 'X-aws-ec2-metadata-token-ttl-seconds: 21600'"
        ));
    }

    return trim(shell_exec(
        "curl -s -H 'X-aws-ec2-metadata-token: {$token}' " .
        "http://169.254.169.254/latest/meta-data/{$path}"
    ));
}

$message = "";

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['stress'])) {

    // Adjust based on your instance size
    shell_exec("nohup stress --cpu $(nproc) --timeout 300 > /dev/null 2>&1 &");

    $message = "CPU stress started for 300 seconds.";
}

$instanceId = getMetadata("instance-id");
$privateIp = getMetadata("local-ipv4");
$publicIp = getMetadata("public-ipv4");
$availabilityZone = getMetadata("placement/availability-zone");

$region = preg_replace('/[a-z]$/', '', $availabilityZone);

$hostname = gethostname();

$load = sys_getloadavg();
$currentLoad = round($load[0], 2);

$uptime = trim(shell_exec("uptime -p"));

?>
<!DOCTYPE html>
<html>
<head>
    <title>AWS Auto Scaling Demo</title>

    <meta http-equiv="refresh" content="5">

    <style>

        body {
            font-family: Arial, sans-serif;
            background: #f4f6f8;
            margin: 0;
            padding: 40px;
        }

        .container {
            max-width: 900px;
            margin: auto;
        }

        .card {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 3px 10px rgba(0,0,0,.1);
        }

        h1 {
            margin-top: 0;
            color: #232f3e;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit,minmax(250px,1fr));
            gap: 15px;
            margin-top: 20px;
        }

        .info {
            background: #fafafa;
            border-left: 4px solid #ff9900;
            padding: 15px;
            border-radius: 6px;
        }

        .label {
            font-size: 12px;
            color: #695656;
            text-transform: uppercase;
        }

        .value {
            font-size: 18px;
            margin-top: 5px;
            word-break: break-all;
        }

        .button-container {
            margin-top: 30px;
            text-align: center;
        }

        button {
            background: #ff9900;
            color: white;
            border: none;
            padding: 15px 30px;
            font-size: 18px;
            border-radius: 8px;
            cursor: pointer;
        }

        button:hover {
            background: #e88a00;
        }

        .success {
            margin-top: 20px;
            color: green;
            text-align: center;
            font-weight: bold;
        }

        .footer {
            text-align: center;
            margin-top: 25px;
            color: #666;
        }

        .load-high {
            color: red;
            font-weight: bold;
        }

        .load-normal {
            color: green;
            font-weight: bold;
        }

    </style>
</head>
<body>

<div class="container">

    <div class="card">

        <h1>AWS EC2 Auto Scaling Demo</h1>

        <div class="grid">

            <div class="info">
                <div class="label">Instance ID</div>
                <div class="value"><?= htmlspecialchars($instanceId) ?></div>
            </div>

            <div class="info">
                <div class="label">Hostname</div>
                <div class="value"><?= htmlspecialchars($hostname) ?></div>
            </div>

            <div class="info">
                <div class="label">Private IP</div>
                <div class="value"><?= htmlspecialchars($privateIp) ?></div>
            </div>

            <div class="info">
                <div class="label">Public IP</div>
                <div class="value"><?= htmlspecialchars($publicIp) ?></div>
            </div>

            <div class="info">
                <div class="label">Availability Zone</div>
                <div class="value"><?= htmlspecialchars($availabilityZone) ?></div>
            </div>

            <div class="info">
                <div class="label">Region</div>
                <div class="value"><?= htmlspecialchars($region) ?></div>
            </div>

            <div class="info">
                <div class="label">CPU Load</div>
                <div class="value <?= ($currentLoad > 2 ? 'load-high' : 'load-normal') ?>">
                    <?= $currentLoad ?>
                </div>
            </div>

            <div class="info">
                <div class="label">Uptime</div>
                <div class="value"><?= htmlspecialchars($uptime) ?></div>
            </div>

            <div class="info">
                <div class="label">Current Time</div>
                <div class="value"><?= date('Y-m-d H:i:s') ?></div>
            </div>

        </div>

        <?php if ($message): ?>
            <div class="success">
                <?= htmlspecialchars($message) ?>
            </div>
        <?php endif; ?>

        <div class="button-container">

            <form method="POST">

                <button type="submit" name="stress">
                    🚀 Generate CPU Load
                </button>

            </form>

        </div>

        <div class="footer">
            Auto-refreshing every 5 seconds
        </div>

    </div>

</div>

</body>
</html>