How the configuration works:
1) When the application is opened, synchronization processing is called and an authorization dialog is displayed on the screen;
2) The user must enter his login and password, which are checked against the data synchronized from the exchange file;
3) Cancellation of authorization or closing the form leads to the immediate termination of the program
4) When loading a new user, he is assigned a default password "12345678", which he can change the first time he tries to enter the program
5) When you first start the program, an account is created with the login "Administrator" and the password "12345678", with which you can enter 
the program to configure synchronization. The first time the administrator logs in, it will also be possible to change the password.

For synchronization to work, you need to set the path to the directory with the exchange file employees.json.
To do this, in the menu Employees->Service->Set parameters sync
