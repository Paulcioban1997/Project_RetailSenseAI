# RetailSense AI Web

Flutter web frontend for the RetailSense AI API.

## Build

```bash
flutter build web --release
```

The compiled site is generated in `build/web`.

## Deploy

### Vercel

1. Import this project in Vercel.
2. Set the output directory to `build/web`.
3. Deploy after running the web build.

### Netlify

1. Run the web build.
2. Publish the `build/web` folder.

## API

The frontend points to the Render API by default in web mode:

`https://project-retailsenseai.onrender.com`

If needed, override it with the `API_BASE_URL` compile-time flag.

## Notes

- The web app opens directly on the dashboard.
- CORS is enabled on the API backend.
- `USE_LOCAL_INFERENCE` is disabled on web so the browser uses the deployed API.
