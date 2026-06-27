import subprocess
import os
import sys

def run_git_command(args):
    print(f"Running: git {' '.join(args)}")
    result = subprocess.run(["git"] + args, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error: {result.stderr.strip()}")
        return False
    if result.stdout.strip():
        print(result.stdout.strip())
    return True

def main():
    # 1. Check if git is installed
    try:
        subprocess.run(["git", "--version"], capture_output=True)
    except FileNotFoundError:
        print("Error: git is not installed or not in your PATH.")
        sys.exit(1)
        
    # 2. Check if repo is initialized
    if not os.path.exists(".git"):
        if not run_git_command(["init"]):
            print("Failed to initialize git repository.")
            sys.exit(1)
            
    # Configure user name and email locally if not set globally/locally
    email_check = subprocess.run(["git", "config", "user.email"], capture_output=True, text=True)
    if not email_check.stdout.strip():
        run_git_command(["config", "user.email", "nhoy14@users.noreply.github.com"])
        
    name_check = subprocess.run(["git", "config", "user.name"], capture_output=True, text=True)
    if not name_check.stdout.strip():
        run_git_command(["config", "user.name", "nhoy14"])
            
    # 3. Add remote origin
    remote_url = "https://github.com/nhoy14/bot-key.git"
    # Try adding remote. If it exists, set the url
    if not run_git_command(["remote", "add", "origin", remote_url]):
        # Remote might already exist, try to set URL
        run_git_command(["remote", "set-url", "origin", remote_url])
        
    # 4. Rename branch to main
    run_git_command(["branch", "-M", "main"])
    
    # 5. Add files
    if not run_git_command(["add", "."]):
        print("Failed to add files to git.")
        sys.exit(1)
        
    # 6. Commit
    run_git_command(["commit", "-m", "Initial commit: licensing server, telegram bot, and MQL5 EAs with online verification"])
    
    # 7. Push
    print("\nPushing to GitHub. If prompted, please complete the login/authorization in your browser/terminal...")
    # Run git push synchronously and let it print directly to stdout/stderr so credentials prompts are visible
    result = subprocess.run(["git", "push", "-u", "origin", "main"])
    if result.returncode == 0:
        print("\n🎉 Project successfully pushed to GitHub!")
    else:
        print("\n❌ Git push failed. Please check your network and GitHub credentials.")

if __name__ == "__main__":
    main()
