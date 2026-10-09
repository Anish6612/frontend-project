const tips = [
  "Version everything: app code AND infrastructure code.",
  "Never store AWS keys in git — use OIDC / IAM roles.",
  "CloudFront OAC beats legacy OAI: private S3, SigV4 only.",
  "Invalidate CloudFront after S3 sync or users see stale files.",
  "One branch (main) -> one pipeline -> one CloudFront distro for learning.",
  "terraform plan before apply. Always.",
  "State belongs in S3 with encryption + locking in prod."
];

function rand(n) { return Math.floor(Math.random() * n); }
function newNum() { document.getElementById("randNum").textContent = rand(100000); }
function newColor() {
  const a = `hsl(${rand(360)} 80% 60%)`, b = `hsl(${rand(360)} 80% 50%)`;
  document.getElementById("swatch").style.background = `linear-gradient(135deg, ${a}, ${b})`;
}
function newTip() { document.getElementById("tip").textContent = tips[rand(tips.length)]; }

document.getElementById("btnNum").onclick = newNum;
document.getElementById("btnColor").onclick = newColor;
document.getElementById("btnTip").onclick = newTip;
document.getElementById("buildTime").textContent = new Date().toISOString();

newNum(); newColor(); newTip();
