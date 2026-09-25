Upload these items to the ROOT of the My-High-School-Journey GitHub repository:

1. Replace project.yml with the project.yml in this package.
2. Replace codemagic.yaml with the codemagic.yaml in this package.
3. Upload the entire Resources folder so the repo contains:
   Resources/Assets.xcassets/AppIcon.appiconset/...

Then in Codemagic run the workflow named:
   iOS TestFlight Upload

This package uses a temporary TestFlight app icon. Replace it with final branding before App Store submission.
