# Kuma Dockerfile for Choreo

# Version

2.1.0

# Releases

Changelog:

All beta changes are also included in this release.
Please go throught them too, in total this relase had 250 PRs merged.
https://github.com/louislam/uptime-kuma/releases/tag/2.1.0-beta.0
https://github.com/louislam/uptime-kuma/releases/tag/2.1.0-beta.1
https://github.com/louislam/uptime-kuma/releases/tag/2.1.0-beta.2
https://github.com/louislam/uptime-kuma/releases/tag/2.0.0-beta.3

### 🆕 New Features
- #6830 feat(notification): add Jira Service Management as a notification provider (Thanks @jankal)
- #6777 feat: add google sheets notification provider (Thanks @dharunashokkumar)

### 💇‍♀️ Improvements
- #6843 feat(discord): add custom message and format presets for notifications (Thanks @epifeny)
- #6804 feat(ntfy): add custom title and message templates for notifications (Thanks @epifeny)

### 🐞 Bug Fixes
- #6845 fix: certificate expiry (use Settings.set instead of Settings.setSetting) (Thanks @epifeny)
- #6841 fix: weblate conflict (Thanks @Aluisio @AnnAngela @cyril59310 @dodog @FunNikita @Kf637 @kurama @mafen @michi-onl @MrEddX @pmontp19)
- #6835 feat(slack): Add option to include monitor group name in notifications (Thanks @dovansy1998)
- #6822 fix: improve monitor list selection behavior (Thanks @frozenflux2)
- #6805 fix: RSS pubDate timezone issue with backend test (#6422) (Thanks @Aqudi)
- #6795 fix: monitor names hidden by tags (Thanks @bittoby)
- #6792 fix: expand/collapse all groups now works with nested groups (Thanks @kurama)
- #6791 Fix bot filtering in generate-changelog.mjs 
- #6789 fix: Add input validation for monitor ID in badge endpoints (Thanks @Angel98518)
- #6783 fix: improve RADIUS client error handling and socket cleanup (Thanks @dive2tech)
- #6778 fix: MongoDB monitor JSON.parse error handling (Thanks @Angel98518)

### ⬆️ Security Fixes

### 🦎 Translation Contributions
- #6853 chore: Translations Update from Weblate (Thanks @2000Arion @Aluisio @AnnAngela @cyril59310 @dodog @jochemp264 @Kf637 @michi-onl @MrEddX)
- #6834 feat(i18n): Add Bavarian German language support 
- #6817 Translations Update from Weblate (Thanks @Aluisio @AnnAngela @dodog @FunNikita @Kf637 @kurama @mafen @michi-onl @MrEddX @pmontp19)
- #6597 chore: Translations Update from Weblate (Thanks @101br03k @2000Arion @aindriu80 @Aluisio @AndyLCQ @AnnAngela @atriwidada @bkzspam @Buchtic @cyril59310 @dodog @Donglingfeng @hackerpro17s @IsayIsee @isfan14 @ivanbratovic @JavierLuna @JWeinelt @Kodashas @michi-onl @MrEddX @simonghpub @superpep @tony-chompoo @Virenbar)
- #6163 feat: add Globalping support (Thanks @radulucut)


### Others
- #6877 chore: npm update 
- #6875 chore: Update final release workflow 
- #6849 feat: Adding monitor_id and heartbeat_id to HaloPSA (Thanks @Yasindu20)
- #6814 chore: Revert "feat: added monitoring for postgres query result" 
- #6787 chore: update to 2.1.0-beta.3 







