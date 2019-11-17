Symlink ***pip3*** to ***pip***

`ln -s /usr/local/bin/pip3 /usr/local/bin/pip`

Remove any previous ***jupyter*** installation

`pip3 uninstall -y jupyter jupyter_core jupyter-client jupyter-console notebook qtconsole nbconvert nbformat`

Installing ***anaconda*** from cask

`brew cask install anaconda`

Symlink ***jupyter*** and ***conda*** from Anaconda environment

`ln -s /usr/local/anaconda3/bin/jupyter /usr/local/bin/jupyter`

`ln -s /usr/local/anaconda3/bin/conda /usr/local/bin/conda`

Install ***matplotlib*** widget 

`conda install -c conda-forge ipympl`

If using the ***Jupter Notebook***

`conda install -c conda-forge widgetsnbextension`

If using ***JupyterLab***

`conda install nodejs`

`jupyter labextension install @jupyter-widgets/jupyterlab-manager`

`jupyter labextension install jupyter-matplotlib`
