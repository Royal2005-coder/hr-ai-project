# HUONG DAN QUAN TRI GITLAB -- DANH CHO MAINTAINER

**Du an:** HR Analytics Text-to-SQL Agent  
**Repository:** https://gitlab.com/boygia757-netizen/hr-ai-project  
**Ngay cap nhat:** 11/02/2026


---


## 1. Cau truc quyen hien tai

### Branch Protection

| Branch | Push | Merge | Force Push | Ghi chu |
|---|---|---|---|---|
| `main` | Chi Maintainer (40) | Chi Maintainer (40) | ❌ Cam | Branch chinh, duoc bao ve |
| `hr_domain_research` | Developer tro len | Developer tro len | ❌ Cam | Branch lam viec cua team |

### Cap do quyen GitLab

| Vai tro | Cap do | Quyen |
|---|---|---|
| Guest (10) | Xem code, tao issue | Khong push/commit |
| Reporter (20) | Xem code, pull, tao issue | Khong push |
| **Developer (30)** | **Clone, pull, push len branch khong protected** | **Khong push len main** |
| Maintainer (40) | Toan quyen tru xoa du an | Push len main, quan ly thanh vien |
| Owner (50) | Toan quyen | Chu du an |

> **Khuyen nghi:** Cap quyen **Developer** cho thanh vien moi. Day la muc quyen an toan nhat cho dev.


---


## 2. Them thanh vien moi

### Cach 1: Qua giao dien GitLab

1. Truy cap: https://gitlab.com/boygia757-netizen/hr-ai-project/-/project_members
2. Nhan **Invite members**
3. Nhap **username hoac email** cua thanh vien
4. Chon **Role**: `Developer`
5. (Tuy chon) Dat **Access expiration date** neu muon gioi han thoi gian
6. Nhan **Invite**

### Cach 2: Qua API (tu dong hoa)

```powershell
# Thay the cac gia tri:
#   TOKEN     = Personal Access Token cua Maintainer
#   USER_ID   = GitLab User ID cua thanh vien moi
#   30        = Access level (30 = Developer)

$token = "glpat-xxxxxxxxxxxxxxxxxxxxx"
$projectId = "79387667"
$headers = @{ "PRIVATE-TOKEN" = $token }

# Tim User ID theo username
$user = Invoke-RestMethod -Uri "https://gitlab.com/api/v4/users?username=ten-username" -Headers $headers
$userId = $user[0].id
Write-Host "User ID: $userId"

# Them thanh vien voi quyen Developer
$body = @{
    user_id = $userId
    access_level = 30
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://gitlab.com/api/v4/projects/$projectId/members" `
    -Method Post -Headers $headers `
    -ContentType "application/json" -Body $body
```


---


## 3. Xem danh sach thanh vien hien tai

### Qua giao dien:
https://gitlab.com/boygia757-netizen/hr-ai-project/-/project_members

### Qua API:
```powershell
$token = "glpat-xxxxxxxxxxxxxxxxxxxxx"
$projectId = "79387667"
$headers = @{ "PRIVATE-TOKEN" = $token }

$members = Invoke-RestMethod -Uri "https://gitlab.com/api/v4/projects/$projectId/members" -Headers $headers
$members | ForEach-Object { "$($_.username) - Access Level: $($_.access_level)" }
```


---


## 4. Xoa hoac thay doi quyen thanh vien

### Thay doi quyen:
```powershell
# Thay doi quyen cua thanh vien (vi du: tu Developer len Maintainer)
$body = @{ access_level = 40 } | ConvertTo-Json

Invoke-RestMethod -Uri "https://gitlab.com/api/v4/projects/$projectId/members/$userId" `
    -Method Put -Headers $headers `
    -ContentType "application/json" -Body $body
```

### Xoa thanh vien:
```powershell
Invoke-RestMethod -Uri "https://gitlab.com/api/v4/projects/$projectId/members/$userId" `
    -Method Delete -Headers $headers
```


---


## 5. Quan ly Protected Branches

### Xem cac branch dang duoc bao ve:
```powershell
Invoke-RestMethod -Uri "https://gitlab.com/api/v4/projects/$projectId/protected_branches" `
    -Headers $headers | ConvertTo-Json -Depth 5
```

### Them protected branch moi:
```powershell
$body = @{
    name = "release/*"
    push_access_level = 40      # Chi Maintainer
    merge_access_level = 30     # Developer co the merge
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://gitlab.com/api/v4/projects/$projectId/protected_branches" `
    -Method Post -Headers $headers `
    -ContentType "application/json" -Body $body
```

### Xoa protected branch:
```powershell
Invoke-RestMethod -Uri "https://gitlab.com/api/v4/projects/$projectId/protected_branches/ten-branch" `
    -Method Delete -Headers $headers
```


---


## 6. Review va Merge -- Merge Request

### Quy trinh review:

1. Thanh vien tao **Merge Request** tu `hr_domain_research` → `main`
2. Maintainer nhan thong bao email/GitLab
3. Truy cap MR, review code thay doi
4. Neu OK: Nhan **Merge**
5. Neu can sua: Comment tren MR, yeu cau thanh vien chinh sua

### Link xem Merge Requests:
https://gitlab.com/boygia757-netizen/hr-ai-project/-/merge_requests


---


## 7. Checklist khi them thanh vien moi

```
[ ] 1. Them thanh vien voi quyen Developer
[ ] 2. Gui link tai lieu ONBOARDING_GUIDE.md cho thanh vien
[ ] 3. Cung cap thong tin ket noi SQL Server (host, port, user, pass)
[ ] 4. Huong dan tao Gemini API Key (moi nguoi tu tao)
[ ] 5. Xac nhan thanh vien da clone, chay duoc he thong, push duoc code
```


---

*Tai lieu nay chi danh cho quan tri vien (Maintainer) cua du an.*  
*Phien ban 1.0 — Ngay 11/02/2026*
