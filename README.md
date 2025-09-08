# Hotwire Playwright Sample

CupriteとPlaywrightのシステムテスト比較検証用のサンプルアプリケーションです。

## セットアップ

```bash
git clone https://github.com/atsumu22/hotwire_playwright_sample.git
cd hotwire_playwright_sample

bundle install
rails db:create db:migrate db:seed

# Playwright使用の場合のみ
bundle exec playwright install chromium
```

## テスト実行

### Cupriteドライバ
```bash
git checkout cuprite
bundle exec rspec spec/system/
```

### Playwrightドライバ
```bash
git checkout playwright  
bundle exec rspec spec/playwright/
```