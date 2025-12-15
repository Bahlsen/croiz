Frontend Deploy Checklist

1. Build the web app

```powershell
cd frontend
flutter clean
flutter pub get
flutter build web --release
```

2. Verify indexed puzzle assets are present in the build

```powershell
python frontend/tools/verify_build_index.py
# Expected: "All indexed paths are present in the build assets." and exit code 0
```

3. If verification fails, regenerate and sync:

```powershell
python frontend/tools/generate_puzzles_index.py
python frontend/tools/sync_assets_to_build.py
python frontend/tools/verify_build_index.py
```

4. Deploy build/web to your static host (example for GitHub Pages):

- Copy `frontend/build/web` to the branch or upload via your CI pipeline.

5. Invalidate cache / CDN

- Cloudflare: purge cache for the site (or specific `assets/assets/data/*` paths).
- Netlify: trigger a new deploy (site builds from repo) or use Netlify _Clear cache and redeploy_.
- GitHub Pages + CDN: ensure you force refresh or bump asset URLs (service worker) by updating `version.json` or the service worker.

6. Post-deploy verification

- Open the site and check browser DevTools Network tab for any 404s to `assets/assets/data/*`.
- If service worker is active, either unregister it in DevTools Application → Service Workers or send a `skipWaiting` message from the page to force activation, then refresh.

7. Optional CI: Add a pipeline step that runs `flutter build web` and `python frontend/tools/verify_build_index.py` and fails the pipeline if verification fails.

Notes

- The repository includes `frontend/tools/sync_assets_to_build.py` which mirrors `frontend/assets/data/` into the build output when needed. Use it after `flutter build web` if per-puzzle JSON files are missing from the build.
- If you use a caching layer or CDN, service worker files may be cached—invalidate or update the service worker to avoid stale RESOURCES mappings.
