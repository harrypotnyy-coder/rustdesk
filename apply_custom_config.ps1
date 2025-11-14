# PowerShell script to apply Probation Desk custom configuration
# Run this script after git pull and submodule init

Write-Host "Applying Probation Desk custom configuration..." -ForegroundColor Green

$configFile = "libs\hbb_common\src\config.rs"

if (!(Test-Path $configFile)) {
    Write-Host "Error: $configFile not found!" -ForegroundColor Red
    Write-Host "Make sure you run 'git submodule update --init --recursive' first" -ForegroundColor Yellow
    exit 1
}

# Read the file
$content = Get-Content $configFile -Raw

# Replace APP_NAME
$content = $content -replace 'pub static ref APP_NAME: RwLock<String> = RwLock::new\("RustDesk"\.to_owned\(\)\);', 'pub static ref APP_NAME: RwLock<String> = RwLock::new("Probation Desk".to_owned());'

# Replace RENDEZVOUS_SERVERS
$content = $content -replace 'pub const RENDEZVOUS_SERVERS: &\[&str\] = &\["rs-ny\.rustdesk\.com"\];', 'pub const RENDEZVOUS_SERVERS: &[&str] = &["85.113.27.42"];'

# Replace RS_PUB_KEY
$content = $content -replace 'pub const RS_PUB_KEY: &str = "OeVuKk5nlHiXp\+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw=";', 'pub const RS_PUB_KEY: &str = "iO8zyX5mfMJwBiz6w6m7+0kmrygpEKsVU2qL4vNY3k8=";'

# Add default password to get_permanent_password function
if ($content -notmatch "55605560aaA!") {
    $passwordPattern = '(\s+pub fn get_permanent_password\(\) -> String \{\s+let mut password = CONFIG\.read\(\)\.unwrap\(\)\.password\.clone\(\);\s+if password\.is_empty\(\) \{\s+if let Some\(v\) = HARD_SETTINGS\.read\(\)\.unwrap\(\)\.get\("password"\) \{\s+password = v\.to_owned\(\);\s+\}\s+\}\s+)(password\s+\})'
    $replacement = '$1// Default password for Probation Desk custom build
        if password.is_empty() {
            password = "55605560aaA!".to_owned();
        }
        $2'
    $content = $content -replace $passwordPattern, $replacement
}

# Write back to file
$content | Set-Content $configFile -NoNewline

Write-Host "Configuration applied successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Changes made:" -ForegroundColor Cyan
Write-Host "  - APP_NAME: Probation Desk" -ForegroundColor White
Write-Host "  - Server: 85.113.27.42:21116" -ForegroundColor White
Write-Host "  - Relay: 85.113.27.42:21117" -ForegroundColor White
Write-Host "  - Server Key: iO8zyX5mfMJwBiz6w6m7+0kmrygpEKsVU2qL4vNY3k8=" -ForegroundColor White
Write-Host "  - Default Password: 55605560aaA!" -ForegroundColor White
Write-Host ""
Write-Host "You can now run: python build.py --flutter" -ForegroundColor Green
