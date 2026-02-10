# HUONG DAN ONBOARDING -- DU AN HR ANALYTICS TEXT-TO-SQL

**Du an:** HR Analytics -- He thong du bao nghi viec va truy van insight nhan su  
**Ma so de tai:** 252BIM500601  
**Repository:** https://gitlab.com/boygia757-netizen/hr-ai-project  
**Phien ban:** 3.0 | Ngay cap nhat: 11/02/2026


---


## MUC LUC

1. [Gioi thieu du an va kien truc tong the](#1-gioi-thieu-du-an-va-kien-truc-tong-the)
2. [Yeu cau phan cung va phan mem](#2-yeu-cau-phan-cung-va-phan-mem)
3. [Yeu cau quyen truy cap](#3-yeu-cau-quyen-truy-cap)
4. [Cai dat moi truong buoc dau tien](#4-cai-dat-moi-truong-buoc-dau-tien)
5. [Clone du an tu GitLab](#5-clone-du-an-tu-gitlab)
6. [Cau hinh moi truong (.env)](#6-cau-hinh-moi-truong-env)
7. [Khoi dong he thong](#7-khoi-dong-he-thong)
8. [Kiem tra he thong hoat dong](#8-kiem-tra-he-thong-hoat-dong)
9. [Huong dan su dung giao dien Wren AI](#9-huong-dan-su-dung-giao-dien-wren-ai)
10. [Quy trinh lam viec voi Git](#10-quy-trinh-lam-viec-voi-git)
11. [Cau truc thu muc du an](#11-cau-truc-thu-muc-du-an)
12. [Xu ly loi thuong gap](#12-xu-ly-loi-thuong-gap)
13. [Quy tac bao mat bat buoc](#13-quy-tac-bao-mat-bat-buoc)
14. [Lien he ho tro](#14-lien-he-ho-tro)


---


## 1. Gioi thieu du an va kien truc tong the

### 1.1 Du an lam gi?

Du an HR Analytics xay dung mot **tro ly ao** cho phep nhan su (HR) hoi dap du lieu bang **tieng Viet** ma khong can biet SQL. He thong se tu dong:

- Chuyen cau hoi tieng Viet thanh cau lenh SQL
- Truy van co so du lieu SQL Server
- Tra ve ket qua dang bang va bieu do truc quan

**Vi du cau hoi:** "10 nhan vien co nguy co nghi viec cao nhat la ai?" → He thong tra ve danh sach day du voi ten, phong ban, xac suat nghi viec, muc rui ro.

### 1.2 Kien truc tong the

```
                ┌─────────────────┐
                │   Nguoi dung    │
                │  (Trinh duyet)  │
                └────────┬────────┘
                         │ http://localhost:3000
                         ▼
                ┌─────────────────┐
                │    Wren UI      │  ← Giao dien web (Next.js)
                │   Port 3000    │
                └────────┬────────┘
                         │
              ┌──────────┼──────────┐
              ▼                     ▼
     ┌─────────────────┐  ┌─────────────────┐
     │ Wren AI Service │  │   Wren Engine   │
     │   Port 5555     │  │   Port 8080     │
     │  (Python/LLM)   │  │  (Java/SQL)     │
     └────────┬────────┘  └────────┬────────┘
              │                     │
    ┌─────────┼─────────┐         │
    ▼                   ▼         ▼
┌────────┐    ┌──────────┐  ┌──────────────┐
│Gemini  │    │  Qdrant  │  │  SQL Server  │
│  API   │    │Port 6333 │  │  Port 1433   │
│(Google)│    │(VectorDB)│  │ (Database)   │
└────────┘    └──────────┘  └──────────────┘
```

**Giai thich cac thanh phan:**

| Thanh phan | Vai tro | Cong nghe |
|---|---|---|
| **Wren UI** | Giao dien web, noi nguoi dung nhap cau hoi | Next.js, React |
| **Wren AI Service** | Bo nao AI: chuyen cau hoi → SQL, tao bieu do | Python, LiteLLM, Gemini API |
| **Wren Engine** | Thuc thi SQL, quan ly semantic layer | Java |
| **Qdrant** | Luu tru vector embeddings cho SQL Pairs/Instructions | Vector Database |
| **Ibis Server** | Ket noi toi SQL Server database | Python |
| **SQL Server** | Co so du lieu HR Analytics (7 bang, 2 view) | Microsoft SQL Server |


---


## 2. Yeu cau phan cung va phan mem

### 2.1 Phan cung toi thieu

| Thanh phan | Toi thieu | Khuyen nghi |
|---|---|---|
| RAM | 8 GB | 16 GB |
| O cung trong | 10 GB | 20 GB |
| CPU | 4 cores | 8 cores |
| Mang | Internet on dinh | Internet on dinh |

### 2.2 Phan mem can cai truoc

> **QUAN TRONG:** Cai dat TAT CA phan mem duoi day TRUOC khi thuc hien cac buoc tiep theo.

#### a) Docker Desktop (BAT BUOC)

1. Truy cap: https://www.docker.com/products/docker-desktop/
2. Tai phien ban **Docker Desktop for Windows**
3. Chay file cai dat, lam theo huong dan
4. Khoi dong lai may tinh khi duoc yeu cau
5. Mo Docker Desktop va doi den khi icon o taskbar chuyen sang **mau xanh** (Engine running)

**Kiem tra Docker da cai thanh cong:**
```powershell
docker --version
# Ket qua mong doi: Docker version 27.x.x (hoac moi hon)

docker compose version
# Ket qua mong doi: Docker Compose version v2.x.x
```

#### b) Git (BAT BUOC)

1. Truy cap: https://git-scm.com/download/win
2. Tai va cai dat, giu cac tuy chon mac dinh
3. Khi duoc hoi "Default Branch Name", chon **main**

**Kiem tra Git da cai thanh cong:**
```powershell
git --version
# Ket qua mong doi: git version 2.4x.x (hoac moi hon)
```

#### c) Visual Studio Code (KHUYEN NGHI)

1. Truy cap: https://code.visualstudio.com/
2. Tai va cai dat phien ban Windows
3. Cai extension **Docker** (ms-azuretools.vscode-docker) de xem logs container de dang hon

#### d) Trinh duyet web

- Google Chrome, Microsoft Edge, hoac Firefox phien ban moi nhat


---


## 3. Yeu cau quyen truy cap

### 3.1 GitLab

Ban can duoc cap quyen **Developer** tren du an GitLab.

> **Luu y ve quyen Developer:**
> - ✅ DUOC PHEP: Clone du an, doc code, tao branch, push len branch `hr_domain_research`
> - ✅ DUOC PHEP: Tao Merge Request tu `hr_domain_research` vao `main`
> - ❌ KHONG DUOC: Push truc tiep len branch `main`
> - ❌ KHONG DUOC: Xoa branch `main`, thay doi cai dat du an
> - ❌ KHONG DUOC: Chinh sua Protected Branches, thay doi quyen thanh vien

**De xin quyen truy cap:**

1. Gui email cho quan tri vien du an (Lead/Maintainer) voi noi dung:
   - Ho ten day du
   - Username GitLab cua ban
   - Email GitLab cua ban
2. Quan tri vien se moi ban vao du an voi vai tro **Developer**
3. Ban se nhan email moi tham gia → nhan **Accept** de xac nhan

### 3.2 Gemini API Authentication

He thong su dung **Gemini API** (Google) de goi LLM va Embedder. API key da duoc **nhung san trong file `.env`** va commit len GitLab private repo.

**Yeu cau:**
- Khong can tai khoan Google Cloud
- Khong can cai Google Cloud SDK (gcloud)
- Khong can tao API key rieng
- Chi can clone du an ve la co san file `.env` voi `GEMINI_API_KEY` da cau hinh

> ✅ **DON GIAN:** Team chi can pull code tu GitLab ve va chay. Moi thu da duoc cau hinh san.

### 3.3 SQL Server Database

He thong ket noi toi SQL Server database `HR_Analytics`. Ban can thong tin sau tu quan tri vien:

| Thong tin | Mo ta |
|---|---|
| Host | Dia chi IP hoac hostname cua SQL Server |
| Port | Mac dinh: 1433 |
| Database | HR_Analytics |
| Username | Account SQL Server |
| Password | Mat khau account |

> Database da duoc cau hinh san trong Wren AI. Neu ban khong thay doi database, khong can thay doi gi.


---


## 4. Cai dat moi truong buoc dau tien

### 4.1 Cau hinh Git tren may cua ban

Mo **PowerShell** (hoac Terminal trong VS Code) va chay:

```powershell
# Thay bang ten va email cua BAN
git config --global user.name "Ho Ten Cua Ban"
git config --global user.email "email-gitlab-cua-ban@gmail.com"

# Cau hinh credential helper de luu mat khau (khong phai nhap lai moi lan)
git config --global credential.helper manager
```

### 4.2 Tao GitLab Personal Access Token (de xac thuc khi push code)

1. Dang nhap GitLab: https://gitlab.com/
2. Vao: **User Settings** → **Access Tokens** (hoac truy cap truc tiep: https://gitlab.com/-/user_settings/personal_access_tokens)
3. Nhan **Add new token**
4. Dien thong tin:
   - **Token name:** `hr-ai-dev` (hoac ten tuy chon)
   - **Expiration date:** Chon ngay het han (khuyen nghi 6 thang - 1 nam)
   - **Scopes:** Tick vao ✅ `read_repository` va ✅ `write_repository`
5. Nhan **Create personal access token**
6. **QUAN TRONG:** Copy token ngay lap tuc va luu o noi an toan. Token chi hien thi 1 lan duy nhat!
   - Token co dang: `glpat-xxxxxxxxxxxxxxxxxxxx`

> ⚠️ **Luu token nay de dung khi push code.** Khi Git hoi mat khau, nhap token nay thay vi mat khau GitLab.


---


## 5. Clone du an tu GitLab

### 5.1 Mo Terminal va clone

```powershell
# Di chuyen den thu muc ban muon luu du an
cd C:\Users\<TenUser>

# Clone du an
git clone https://gitlab.com/boygia757-netizen/hr-ai-project.git

# Khi duoc hoi mat khau:
#   Username: <username-gitlab-cua-ban>
#   Password: <Personal Access Token da tao o Buoc 4.2>
```

### 5.2 Chuyen sang branch lam viec

> **TUYET DOI KHONG lam viec tren branch `main`.** Moi thay doi phai duoc thuc hien tren branch `hr_domain_research`.

```powershell
# Di chuyen vao thu muc du an
cd hr-ai-project

# Chuyen sang branch lam viec
git checkout hr_domain_research

# Xac nhan dang o dung branch
git branch
# Ket qua mong doi:
#   main
# * hr_domain_research    ← Dau * cho thay ban dang o branch nay
```

### 5.3 Cap nhat code moi nhat

```powershell
# Luon pull code moi nhat truoc khi bat dau lam viec
git pull origin hr_domain_research
```


---


## 6. Cau hinh moi truong (.env)

### 6.1 File .env da co san

Khi ban clone du an tu GitLab, file `.env` da co san trong thu muc `WrenAI/docker/`. File nay chua:
- `GEMINI_API_KEY` — API key chung cho team, da nhung san
- `COMPOSE_PROJECT_NAME` — Ten project Docker
- `USER_UUID` — ID nguoi dung

> ✅ **KHONG CAN** cai Google Cloud SDK (gcloud)
> ✅ **KHONG CAN** tao API key rieng
> ✅ **KHONG CAN** chay `gcloud auth login` hay bat ky lenh xac thuc nao
> ✅ Chi can pull code ve va chay

### 6.2 Kiem tra file .env ton tai

```powershell
# Di chuyen vao thu muc docker
cd C:\Users\<TenUser>\hr-ai-project\WrenAI\docker

# Kiem tra file .env ton tai
Test-Path .env
# Ket qua mong doi: True
```

### 6.3 Kiem tra noi dung file .env

```powershell
# Kiem tra cac bien quan trong trong .env
Select-String -Path .env -Pattern "GEMINI_API_KEY|USER_UUID|COMPOSE_PROJECT_NAME"
```

**Ket qua mong doi:**
```
.env:1:COMPOSE_PROJECT_NAME=wrenai
.env:X:GEMINI_API_KEY=AIza...  (PHAI co gia tri)
.env:X:USER_UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  (PHAI co gia tri)
```

> Neu `GEMINI_API_KEY` hoac `USER_UUID` trong, lien he quan tri vien du an.

### 6.4 Cau hinh config.yaml (da cau hinh san)

File `WrenAI/docker/config.yaml` da duoc cau hinh san voi cac model:

| Thanh phan | Model | Ghi chu |
|---|---|---|
| **LLM** | `gemini/gemini-2.5-flash` | Mo hinh ngon ngu lon |
| **Embedder** | `gemini/gemini-embedding-001` | Mo hinh embedding |

> Ban **KHONG CAN** chinh sua file `config.yaml` truoc khi da xac nhan truoc voi team. Cau hinh da san sang de chay.


---


## 7. Khoi dong he thong

### 7.1 Dam bao Docker Desktop dang chay

- Kiem tra icon Docker o goc phai taskbar (system tray) phai **mau xanh**
- Neu icon mau cam hoac khong thay, mo Docker Desktop va doi khoi dong xong

### 7.2 Khoi dong tat ca dich vu

```powershell
# Di chuyen vao thu muc docker (neu chua o do)
cd C:\Users\<TenUser>\hr-ai-project\WrenAI\docker

# Khoi dong he thong (lan dau se tai images, mat 5-10 phut)
docker compose up -d
```

**Ket qua mong doi:**
```
[+] Running 6/6
 ✔ Container wrenai-qdrant-1            Started
 ✔ Container wrenai-wren-engine-1       Started
 ✔ Container wrenai-ibis-server-1       Started
 ✔ Container wrenai-wren-ai-service-1   Started
 ✔ Container wrenai-bootstrap-1         Started
 ✔ Container wrenai-wren-ui-1           Started
```

### 7.3 Kiem tra tat ca container dang chay

```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**Ket qua mong doi (6 container, tat ca deu "Up"):**

| Container | Status | Ports |
|---|---|---|
| wrenai-wren-ui-1 | Up | 0.0.0.0:3000→3000 |
| wrenai-wren-ai-service-1 | Up | 0.0.0.0:5555→5555 |
| wrenai-wren-engine-1 | Up | 0.0.0.0:8080→8080 |
| wrenai-qdrant-1 | Up | 0.0.0.0:6333→6333 |
| wrenai-ibis-server-1 | Up | 0.0.0.0:8000→8000 |
| wrenai-bootstrap-1 | Exited (0) | — |

> **Luu y:** Container `bootstrap` se co trang thai "Exited (0)" sau khi khoi tao xong. Day la binh thuong.

### 7.4 Doi AI Service san sang (QUAN TRONG)

AI Service can 1-2 phut de khoi dong hoan tat. Kiem tra:

```powershell
# Kiem tra health cua AI Service
Invoke-RestMethod -Uri "http://localhost:5555/health" -Method Get
```

**Ket qua mong doi:**
```
status
------
ok
```

> Neu nhan duoc loi "Unable to connect", doi them 30 giay roi thu lai.


---


## 8. Kiem tra he thong hoat dong

### 8.1 Mo giao dien web

Mo trinh duyet va truy cap:

```
http://localhost:3000
```

### 8.2 Kiem tra lan dau (Onboarding)

Neu la lan dau chay tren may cua ban:
- He thong se hien thi trang **Onboarding** — ket noi database
- Chon loai database: **SQL Server**
- Nhap thong tin ket noi SQL Server (hoi quan tri vien du an)
- Lam theo cac buoc chon bang, cau hinh relationships
- He thong se tu dong deploy model

> **Neu he thong da duoc cau hinh truoc:** Giao dien se hien thi ngay trang **Home** voi o nhap cau hoi.

### 8.3 Thu nghiem cau hoi mau

Nhap mot trong cac cau hoi sau vao o "Ask a question":

| Cau hoi mau | Ket qua mong doi |
|---|---|
| 10 nhan vien co nguy co nghi viec cao nhat | Bang 10 nhan vien voi ten, phong ban, xac suat, risk level |
| Ty le nghi viec theo phong ban | Bang thong ke ty le nghi viec tung phong ban |
| So sanh luong trung binh giua nam va nu | Bang so sanh voi cot Gender, avg salary |
| Bao nhieu nhan vien lam them gio | So luong va ty le nhan vien overtime |

### 8.4 Kiem tra chart (bieu do)

Sau khi co ket qua SQL, nhan nut **Chart** o goc phai de xem bieu do truc quan. He thong ho tro:
- Bieu do cot (Bar Chart)
- Bieu do duong (Line Chart)  
- Bieu do tron (Donut Chart)
- Bieu do cot xep chong (Stacked Bar)


---


## 9. Huong dan su dung giao dien Wren AI

### 9.1 Trang Home -- Dat cau hoi

1. Nhap cau hoi tieng Viet vao o tim kiem
2. He thong se:
   - Phan tich cau hoi (Retrieving...)
   - Tao SQL (Generating...)
   - Tra ve ket qua bang va bieu do

### 9.2 Trang Modeling -- Xem mo hinh du lieu

- Xem danh sach cac bang (Models) va view
- Xem quan he giua cac bang (Relationships)
- Xem mo ta tung cot (Metadata)

### 9.3 Trang Knowledge -- SQL Pairs va Instructions

**SQL Pairs** (cac cap cau hoi - SQL mau):
- He thong da co 18 SQL Pairs lam vi du cho AI
- Khi ban dat cau hoi tuong tu, AI se tham khao cac mau nay

**Instructions** (quy tac nghiep vu):
- 13 quy tac dat ten, xu ly NULL, format so, dieu kien loc...
- Giup AI tao SQL chuan xac hon

### 9.4 Dung he thong

```powershell
# Di chuyen vao thu muc docker
cd C:\Users\<TenUser>\hr-ai-project\WrenAI\docker

# Dung tat ca dich vu
docker compose down

# Hoac dung va xoa du lieu (chi khi muon reset hoan toan):
# docker compose down -v
```


---


## 10. Quy trinh lam viec voi Git

### 10.1 NGUYEN TAC VANG -- QUY TAC BAT BUOC

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ❌  KHONG BAO GIO push truc tiep len branch "main"         ║
║   ✅  LUON lam viec tren branch "hr_domain_research"          ║
║   ✅  Tao Merge Request khi muon dua code vao main            ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

> Branch `main` da duoc **bao ve (Protected)**. He thong se **tu choi** moi lenh push truc tiep len `main` tu tai khoan Developer. Chi Maintainer (quan tri vien) moi co quyen merge vao `main`.

### 10.2 Quy trinh lam viec hang ngay

```
  Buoc 1          Buoc 2          Buoc 3         Buoc 4         Buoc 5
  Pull moi    →   Lam viec    →   Commit     →   Push       →   Tao MR
  nhat code       va test         thay doi        len GitLab     (tuy chon)
```

#### Buoc 1: Cap nhat code moi nhat

```powershell
cd C:\Users\<TenUser>\hr-ai-project

# Dam bao dang o dung branch
git checkout hr_domain_research

# Lay code moi nhat
git pull origin hr_domain_research
```

#### Buoc 2: Lam viec va thu nghiem

- Chinh sua code, them SQL Pairs, cap nhat Instructions...
- Test tren local (docker compose up -d, mo localhost:3000)

#### Buoc 3: Commit thay doi

```powershell
# Xem danh sach file da thay doi
git status

# Them tat ca file thay doi
git add .

# HOAC them tung file cu the
git add WrenAI/docker/config.yaml
git add TAI_LIEU_DU_AN_HR_ANALYTICS.md

# Commit voi message mo ta ro rang
git commit -m "feat: them SQL Pair cho truy van luong theo phong ban"
```

**Quy tac viet commit message:**

| Tien to | Y nghia | Vi du |
|---|---|---|
| `feat:` | Them tinh nang moi | `feat: them 5 SQL Pairs cho phong ban` |
| `fix:` | Sua loi | `fix: sua loi query NULL values` |
| `docs:` | Cap nhat tai lieu | `docs: cap nhat huong dan su dung` |
| `refactor:` | Tai cau truc code | `refactor: toi uu config embedder` |

#### Buoc 4: Push len GitLab

```powershell
# Push len branch hr_domain_research
git push origin hr_domain_research

# Khi duoc hoi mat khau:
#   Username: <username-gitlab-cua-ban>
#   Password: <Personal Access Token>
```

#### Buoc 5: Tao Merge Request (khi code da san sang)

1. Truy cap: https://gitlab.com/boygia757-netizen/hr-ai-project/-/merge_requests/new
2. **Source branch:** `hr_domain_research`
3. **Target branch:** `main`
4. Dien **Title** mo ta thay doi
5. Dien **Description** chi tiet nhung gi da lam
6. Assign **Reviewer** la quan tri vien du an
7. Nhan **Create merge request**

> Quan tri vien se review va merge code cua ban vao `main`.

### 10.3 Xu ly xung dot (Merge Conflicts)

Neu khi pull ma gap xung dot:

```powershell
# Xem file bi xung dot
git status

# Mo file bi xung dot, tim cac dong:
# <<<<<<< HEAD
# (code cua ban)
# =======
# (code tu remote)
# >>>>>>> origin/hr_domain_research

# Sua file, giu lai phan code dung
# Xoa cac dong <<<, ===, >>>

# Sau khi sua xong
git add .
git commit -m "fix: resolve merge conflict"
git push origin hr_domain_research
```


---


## 11. Cau truc thu muc du an

```
hr-ai-project/
│
├── .gitignore                          ← Danh sach file KHONG commit len Git
├── ONBOARDING_GUIDE.md                 ← TAI LIEU NAY
├── TAI_LIEU_DU_AN_HR_ANALYTICS.md      ← Tai lieu ky thuat chi tiet
│
├── WrenAI/                             ← Engine chinh cua he thong
│   └── docker/
│       ├── .env.example                ← FILE MAU de tao .env
│       ├── .env                        ← Cau hinh he thong (GEMINI_API_KEY, UUID)
│       ├── config.yaml                 ← Cau hinh LLM va Embedder
│       ├── docker-compose.yaml         ← Cau hinh Docker containers
│       └── data/                       ← Du lieu runtime (khong commit)
│
├── legacy/                             ← SQL scripts cu (tham khao)
│   ├── init-db.sql                     ← Tao bang va nhap du lieu
│   ├── create_actionable_views.sql     ← Tao view phan tich
│   └── setup_db_mail_template.sql      ← Cau hinh email canh bao
│
└── notebooks/                          ← Jupyter Notebooks
    ├── HR_Analytics_Project_Final.ipynb ← Mo hinh du bao nghi viec
    ├── WA_Fn-UseC_-HR-Employee-Attrition.csv  ← Du lieu goc IBM HR
    └── README.md                       ← Huong dan chay notebook
```

### Cac file/thu muc QUAN TRONG can biet:

| File | Muc do | Mo ta |
|---|---|---|
| `WrenAI/docker/.env` | Cau hinh | Chua GEMINI_API_KEY va cau hinh he thong (da commit trong private repo) |
| `WrenAI/docker/.env.example` | Tham khao | Mau de tao file .env |
| `WrenAI/docker/docker-compose.yaml` | Cau hinh | Dinh nghia 6 Docker services |
| `WrenAI/docker/config.yaml` | Cau hinh | Model AI (Gemini API), Embedder settings |
| `TAI_LIEU_DU_AN_HR_ANALYTICS.md` | Tai lieu | Mo ta ky thuat chi tiet du an |


---


## 12. Xu ly loi thuong gap

### 12.1 Loi: "Cannot connect to Docker daemon"

**Nguyen nhan:** Docker Desktop chua chay.

**Cach xu ly:**
```powershell
# Mo Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Doi 30-60 giay cho Docker khoi dong
# Kiem tra lai
docker ps
```

### 12.2 Loi: "Port already in use" (cong da bi chiem)

**Nguyen nhan:** Co ung dung khac dang dung cong 3000, 5555, 8080...

**Cach xu ly:**
```powershell
# Tim ung dung dang dung cong 3000
netstat -ano | findstr :3000

# Ket thuc process do (thay PID bang so thuc te)
taskkill /PID <PID> /F

# Khoi dong lai
cd WrenAI\docker
docker compose up -d
```

### 12.3 Loi: AI Service tra ve loi xac thuc ("Permission denied" hoac "API key not valid")

**Nguyen nhan:** `GEMINI_API_KEY` trong file `.env` bi thieu, sai, hoac het han.

**Cach xu ly:**
1. Kiem tra API key trong file .env:
```powershell
cd WrenAI\docker
Select-String -Path .env -Pattern "GEMINI_API_KEY"
# Dam bao dong GEMINI_API_KEY=AIza... co gia tri hop le
```
2. Neu API key trong hoac sai, lien he quan tri vien du an de cap nhat.
3. Khoi dong lai:
```powershell
cd WrenAI\docker
docker compose down
docker compose up -d
```

### 12.4 Loi: "git push rejected" khi push len main

**Nguyen nhan:** Ban dang co push len branch `main` (bi bao ve).

**Cach xu ly:**
```powershell
# Chuyen sang branch dung
git checkout hr_domain_research

# Cherry-pick commit tu main (neu da commit nham tren main)
# Hoac merge:
git merge main

# Push len branch dung
git push origin hr_domain_research
```

### 12.5 Loi: Container wren-ai-service restart lien tuc

**Nguyen nhan:** Thieu hoac sai `GEMINI_API_KEY` trong file `.env`, hoac `config.yaml` bi loi.

**Cach xu ly:**
```powershell
# Xem logs chi tiet
docker logs wrenai-wren-ai-service-1 --tail 50

# Kiem tra GEMINI_API_KEY co trong .env
Select-String -Path "WrenAI\docker\.env" -Pattern "GEMINI_API_KEY"
# Dam bao dong GEMINI_API_KEY=AIza... co gia tri hop le

# Neu thieu hoac sai, lien he quan tri vien du an de cap nhat .env

# Khoi dong lai
cd WrenAI\docker
docker compose down
docker compose up -d
```

### 12.6 Loi: "Authentication failed" khi push code

**Nguyen nhan:** Personal Access Token sai hoac het han.

**Cach xu ly:**
1. Kiem tra token tai: https://gitlab.com/-/user_settings/personal_access_tokens
2. Tao token moi neu can (xem Buoc 4.2)
3. Xoa credential cu:
```powershell
# Xoa credential cu cua GitLab
cmdkey /delete:git:https://gitlab.com

# Push lai, nhap token moi khi duoc hoi
git push origin hr_domain_research
```


---


## 13. Quy tac bao mat bat buoc

### 13.1 Trang thai cac file nhay cam:

| File | Trang thai | Ly do |
|---|---|---|
| `.env` | ✅ Da commit (private repo) | Chua GEMINI_API_KEY chung cho team. Repo la private, chi thanh vien moi truy cap duoc |
| `service-account*.json` | ❌ Khong commit | Chua khoa tai khoan dich vu (neu co) |
| File chua mat khau SQL Server | ❌ Khong commit | Bao ve truy cap database |

### 13.2 Kiem tra truoc khi commit

```powershell
# LUON kiem tra truoc khi commit
git status

# Dam bao KHONG co file nhay cam nao ngoai du kien trong danh sach
# Neu thay file la (service-account*.json, mat khau...), DUNG LAI va lien he quan tri vien
```

### 13.3 Neu lo de lo API key

```powershell
# Neu API key bi lo ra ngoai (public repo, chat, email...):
# 1. Lien he quan tri vien du an NGAY LAP TUC
# 2. Quan tri vien se tao API key moi va cap nhat file .env
# 3. Tat ca thanh vien pull code moi nhat de nhan .env cap nhat

git pull origin hr_domain_research
```

### 13.4 Bao ve API key

- API key chung da nhung san trong `.env` tren GitLab private repo
- **KHONG** chia se API key ra ngoai nhom du an (khong post len forum, mang xa hoi, public repo)
- **KHONG** gui file `.env` qua chat, email cong khai, hoac bat ky kenh khong bao mat nao
- Neu can thay doi API key, lien he quan tri vien du an


---


## 14. Lien he ho tro

### Khi gap van de:

1. **Doc lai tai lieu nay** — Phan 12 (Xu ly loi thuong gap)
2. **Doc tai lieu ky thuat** — File `TAI_LIEU_DU_AN_HR_ANALYTICS.md`
3. **Tao Issue tren GitLab:**
   - Truy cap: https://gitlab.com/boygia757-netizen/hr-ai-project/-/issues/new
   - Mo ta chi tiet loi gap phai
   - Dinh kem screenshot neu co
4. **Lien he quan tri vien du an** (Lead/Maintainer) qua email hoac chat nhom

### Thong tin du an:

| Hang muc | Chi tiet |
|---|---|
| GitLab Repository | https://gitlab.com/boygia757-netizen/hr-ai-project |
| Branch lam viec | `hr_domain_research` |
| Branch chinh (Protected) | `main` |
| Giao dien web (local) | http://localhost:3000 |
| AI Service health check | http://localhost:5555/health |
| LLM Model | `gemini/gemini-2.5-flash` |
| Embedder Model | `gemini/gemini-embedding-001` |
| Ma so de tai | 252BIM500601 |


---


## PHU LUC: BANG KIEM (CHECKLIST) ONBOARDING

Danh dau ✅ khi hoan thanh tung buoc:

```
[ ] 1. Da cai Docker Desktop va chay thanh cong
[ ] 2. Da cai Git va cau hinh user.name, user.email
[ ] 3. Da nhan quyen Developer tren GitLab
[ ] 4. Da tao Personal Access Token tren GitLab
[ ] 5. Da clone du an thanh cong
[ ] 6. Da checkout branch hr_domain_research
[ ] 7. Da kiem tra file .env ton tai (Test-Path .env → True)
[ ] 8. Da kiem tra GEMINI_API_KEY co gia tri trong .env
[ ] 9. Da chay docker compose up -d thanh cong
[ ] 10. Da kiem tra 6 container dang chay (docker ps)
[ ] 11. Da kiem tra AI Service health (localhost:5555/health → ok)
[ ] 12. Da mo giao dien web tai localhost:3000
[ ] 13. Da thu dat 1 cau hoi va nhan duoc ket qua
[ ] 14. Da thu tao 1 commit va push len hr_domain_research
```

**Neu hoan thanh tat ca 14 buoc tren, ban da san sang lam viec!** 🎉


---

*Tai lieu nay duoc tao boi nhom du an HR Analytics. Moi quyen duoc bao luu.*  
*Phien ban 3.0 — Ngay 11/02/2026*
