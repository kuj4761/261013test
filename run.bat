@echo off
chcp 65001 > nul
title 토익 & 비즈니스 영어 단어 학습 앱 (Voca Master)
echo ==========================================================
echo  토익 & 비즈니스 영어 단어 학습 PWA 앱을 시작합니다...
echo ==========================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
pause
