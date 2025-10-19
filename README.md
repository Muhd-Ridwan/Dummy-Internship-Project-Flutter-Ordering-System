# Dummy Project Flutter-Ordering-System (Internship)
Full Stack: Flutter (Front-end). Django with REST Framework (Backend)


How to run it:


1. Download VsCode: (https://code.visualstudio.com/download)
2. Download & Install Python3 -> (https://www.python.org/downloads/)
3. Download & Install PostgreSQL (https://www.postgresql.org/download/)
4. Install PGAdmin4, for setting up the database to connect later : (https://www.pgadmin.org/download/)
5. Download & Install Flutter: (https://docs.flutter.dev/install/manual)
6. Put flutter bin folder in environemnt path
7. Download & Install Flutter Extension in VSCode
8. Create 2 folder. [Backend, Frontend]
9. Open Terminal -> cd Backend create virtual environment: (python3 -m venv venv)
10. Activate venv -> venv\Scripts\Activate -> your terminal will have (venv) in front
11. Install the requirementx.txt -> pip install -r requirements.txt
12. Run py manage.py makemigrations
13. Run py manage.py migrate
14. Load data acounts.json, products.json, cart.json -> (python manage.py loaddata accounts.json) and so on.
15. Run flutter without debugging using chrome.


VOILA ! Now you can run the app

PS: If have some error regarding the psycopg, try to install the binary using pip installation at terminal.
  : Im using terminal (CMD) in VsCode. 
