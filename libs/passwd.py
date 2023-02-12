import tempfile, os
from getpass import getpass

import json
import atexit

# Idea: Could, make the key a tuple. It might already work?

# Note: Might want to use python-gnupg
class Passwd():
    ## TODO: Save on exit

    def __init__(self, pass_file=None, init_empty=False, show_pass=False, save_on_exit=False):
        self.pass_file = pass_file
        self.show_pass = show_pass
    
        
        self.save_on_exit = save_on_exit
        if save_on_exit:
            def on_exit():
                if self._is_loaded and self._modifyed:
                    self.save_file()
            atexit.register(on_exit)


        if init_empty:
            self.data = {}
            self._is_loaded = True
            self._modifyed = True
        else:
            self.data = None
            self._is_loaded = False
            self._modifyed = False

    def get(self, key, input_prompt=None):
        if not self._is_loaded:
            self.load_file()
        if not self.data.__contains__(key):
            self.input_passwd(prompt=input_prompt, key=key)

        return self.data[key];

    def set(self, key, passwd):
        if not self._is_loaded:
            # TODO: This is a bit strange
            self.load_file()
    
        self.data[key] = passwd
        self._modifyed = True

        return self.data[key]

    def input_passwd(self, prompt=None, key=None):
        if prompt:
            print(prompt)

        if self.show_pass:
            pwd = input("Password: ")
        else: 
            pwd = getpass("Password: ")

        if key:
            self.set(key, pwd)
        return pwd

    def update(self, key, passwd=None):
        if not passwd:
            # TODO: Make it posible to cansle passwd update, Ctrl-C works, but it's a bit ugly
            passwd = self.input_passwd()

        self.set(key, passwd)


    def load_file(self, force_load=False):
        if self._is_loaded and not force_load:
            return

        if not os.path.exists(self.pass_file):
            self.data = {}
            self._is_loaded = True
            return

        tempf = tempfile.NamedTemporaryFile('w', delete=False)
        tempf.close()
    
        gpg_options="--yes -q"
        os.system(f"gpg {gpg_options} -o {tempf.name} -d {self.pass_file}")
        with open(tempf.name, 'r') as f:
            self.data = json.load(f)
            # passwd = f.read()
        os.unlink(tempf.name)
        self._is_loaded = True
        # return passwd
        
    def save_file(self):
        # TODO: With this solution, you have to set a new password, for the the password file every time you modify any of the content. Using pygnupg might fix this.

        # TODO: if quite
        print("Saving passwd file")
        with tempfile.NamedTemporaryFile('w', delete=False) as tempf:
            json.dump(self.data, tempf)
            # tempf.write(passwd)
        gpg_options="--yes -q"
        os.system(f"gpg {gpg_options} -o {self.pass_file} -c {tempf.name}")
        os.unlink(tempf.name)

    ## TODO: Make the file a json file, allowing for multiple passwords in the same file. 

    # def store_passwd(self, key, passwd):
    #     """Save paswords to the file self.pass_file

    #     Keyword arguments:
    #     key     -- a key identifying the password
    #     passwd  -- the pasword to store
    #     """

    #     with tempfile.NamedTemporaryFile('w', delete=False) as tempf:
    #         tempf.write(passwd)
    #     os.system(f"gpg -o {self.pass_file} -c {tempf.name}")
    #     os.unlink(tempf.name)
    
    # def read_passewd(self, key):
    #     """Read password from self.pass_file

    #     Keyword arguments:
    #     key     -- a key identifying the password
    #     passwd  -- the pasword to store
    #     """
    #     if not os.path.exists(self.pass_file):
    #         return None

    #     tempf = tempfile.NamedTemporaryFile('w', delete=False)
    #     tempf.close()
    # 
    #     gpg_options="--yes -q"
    #     os.system(f"gpg {gpg_options} -o {tempf.name} -d {self.pass_file}")
    #     with open(tempf.name, 'r') as f:
    #         # TODO: Json
    #         passwd = f.read()
    #     os.unlink(tempf.name)
    #     return passwd

    # def input_passwd(self):
    #     if self.show_pass:
    #         return input("Gmail Password: ")
    #     return getpass("Gmail Password: ")

    # def update_passwd(self, passwd=None):
    #     if not passwd:
    #         # TODO: Make it posible to cansle passwd update, Ctrl-C works, but it's a bit ugly
    #         passwd = self.input_passwd()
    #     self.store_passwd(passwd)

    # ## TODO: Make the file a json file, allowing for multiple passwords in the same file. 
    # def get_passwd(self):
    #     passwd = self.read_passewd()
    #     if not passwd: ## File does not exits
    #         passwd = self.input_passwd()
    #         self.store_passwd(passwd)
    #     return passwd
