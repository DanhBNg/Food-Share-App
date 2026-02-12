@echo off
REM Deploy Food Share Admin Panel to Firebase Hosting

echo Copying web_admin files to public/admin...
xcopy "web_admin\*" "public\admin\" /Y /S /E /I

echo Deploying to Firebase...
firebase deploy

echo.
echo ✅ Deploy complete!
echo 📱 Home: https://food-share-fce9b.web.app
echo 🔧 Admin: https://food-share-fce9b.web.app/admin/
pause
