# FixAdobeAppsPanel

Command-line scripts to fix 'You Don't Have Access To Manage Apps' in the Creative Cloud app.

To use these scripts, your user account needs administrative privileges. 

If you are on a company computer that is managed by an IT department, you might be unable to use these scripts, and you'll need to ask for help.

## Download links and instructions

### For Mac:

First, download:

https://zwettemaan.github.io/FixAdobeAppsPanel/FixAdobeAppsPanel.command

If you want to make sure, first open the file in a text editor and inspect it - it's fairly straightforward code.

Then open a Terminal window, and paste the following three commands (assuming your browser is configured to download to the `~/Downloads` folder). After pasting, hit the &lt;Return&gt; key.
```
cd ~/Downloads
chmod +x FixAdobeAppsPanel.command
xattr -d com.apple.quarantine FixAdobeAppsPanel.command
```
This makes the FixAdobeAppsPanel.command double-clickable.

In the Finder, navigate to your Downloads folder and find FixAdobeAppsPanel.command. 

If you want, you can move the FixAdobeAppsPanel.command to a more convenient location, e.g. ~/Applications.

Double-click the FixAdobeAppsPanel.command. This will launch a Terminal window.

Enter your user password when asked, followed by the &lt;Return&gt; key

<img width="1857" alt="Screenshot 2025-03-09 at 4 43 15 PM" src="https://github.com/user-attachments/assets/88750c8f-47fa-4973-887e-06bb4f2e8cac" />

The Adobe Creative Cloud app should open, hopefully with the Apps panel re-instated

### For Windows:

First, download:

https://zwettemaan.github.io/FixAdobeAppsPanel/FixAdobeAppsPanel.bat

If you want to make sure, first open the file in a text editor and inspect it - it's fairly straightforward code.

In the Windows search zone, type `CMD`

Right-click the option _Command Prompt_ and select _Run as administrator_

<img width="781" alt="Screenshot 2025-03-09 at 4 27 31 PM" src="https://github.com/user-attachments/assets/81c25881-5bfc-4e90-9ac5-ad079b1dad9f" />

Once the CMD terminal window opens up, paste the following two commands (assuming your browser is configured to download to the `Downloads` folder)
```
cd Downloads
FixAdobeAppsPanel
```

<img width="2040" alt="Screenshot 2025-03-09 at 4 40 05 PM" src="https://github.com/user-attachments/assets/bec7e0dc-8ef1-44c5-93c8-c587bf606760" />

The Adobe Creative Cloud app should open, hopefully with the Apps panel re-instated

