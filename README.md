# 1. Create a hidden virtual environment folder in your home directory
python3 -m venv ~/.litellm_env

# 2. Activate the environment (your terminal prompt will change)
source ~/.litellm_env/bin/activate

# 3. Upgrade pip itself to speed things up slightly
pip install --upgrade pip

# 4. Install the proxy (Grab a coffee, let the progress bars do their thing)
pip install 'litellm[proxy]'