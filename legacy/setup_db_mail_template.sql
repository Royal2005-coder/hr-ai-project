-- =============================================
-- Script Cấu hình Database Mail (T-SQL Template)
-- Hướng dẫn:
-- 1. Thay đổi 'YOUR_EMAIL_ADDRESS' thành email của bạn (VD: my.hr.system@gmail.com)
-- 2. Thay đổi 'YOUR_EMAIL_PASSWORD' thành mật khẩu App Password (không phải pass đăng nhập thường)
-- 3. Chạy script này bằng F5 trong SSMS
-- =============================================

USE master;
GO

-- 1. Kích hoạt tính năng Database Mail XPs
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO

-- 2. Tạo Profile 'HR_Notifier'
-- Kiểm tra nếu tồn tại thì không tạo lại
IF NOT EXISTS (SELECT * FROM msdb.dbo.sysmail_profile WHERE name = 'HR_Notifier')
BEGIN
    EXEC msdb.dbo.sysmail_add_profile_sp
        @profile_name = 'HR_Notifier',
        @description = 'Profile tu dong gui bao cao HR';
    PRINT 'Created profile HR_Notifier';
END

-- 3. Tạo Account Gửi Mail (Gmail Example)
-- Thay đổi thông tin bên dưới:
DECLARE @AccountName NVARCHAR(100) = 'HR_Admin_Mailer_Account';
DECLARE @EmailAddress NVARCHAR(100) = 'YOUR_EMAIL_ADDRESS'; -- <== SỬA TẠI ĐÂY
DECLARE @DisplayName NVARCHAR(100) = 'HR AI System';
DECLARE @MailServer NVARCHAR(100) = 'smtp.gmail.com';
DECLARE @Port INT = 587;
DECLARE @Username NVARCHAR(100) = 'YOUR_EMAIL_ADDRESS'; -- <== SỬA TẠI ĐÂY
DECLARE @Password NVARCHAR(100) = 'YOUR_EMAIL_PASSWORD'; -- <== SỬA TẠI ĐÂY (Gmail App Password)

IF NOT EXISTS (SELECT * FROM msdb.dbo.sysmail_account WHERE name = @AccountName)
BEGIN
    EXEC msdb.dbo.sysmail_add_account_sp
        @account_name = @AccountName,
        @email_address = @EmailAddress,
        @display_name = @DisplayName,
        @mailserver_name = @MailServer,
        @port = @Port,
        @enable_ssl = 1,
        @username = @Username,
        @password = @Password;
    PRINT 'Created Account ' + @AccountName;
END

-- 4. Thêm Account vào Profile
EXEC msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = 'HR_Notifier',
    @account_name = @AccountName,
    @sequence_number = 1;
PRINT 'Added Account to Profile';

-- 5. Cấp quyền Public cho Profile (Để mọi user có thể dùng)
EXEC msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = 'HR_Notifier',
    @principal_id = 0, -- 0 for Public, 1 for Guest
    @is_default = 1 ;
PRINT 'Granted public access to profile';

PRINT '=== CẤU HÌNH HOÀN TẤT ===';
PRINT 'Hãy thử gửi mail test:';
PRINT 'EXEC msdb.dbo.sp_send_dbmail @profile_name = ''HR_Notifier'', @recipients = ''gianth23406@st.uel.edu.vn'', @subject = ''Test Mail'', @body = ''Hello from SQL Server'';';
GO
