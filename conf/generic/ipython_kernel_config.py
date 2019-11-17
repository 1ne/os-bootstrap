~/.ipython/profile_default/ipython_kernel_config.py

# %matplotlib inline
c = get_config()

# To render the old-gen plot
# c.IPKernelApp.matplotlib = 'inline'

# To render the new-gen Widget Plot
c.IPKernelApp.matplotlib = 'widget'
