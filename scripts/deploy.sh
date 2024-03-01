#!/bin/bash

## SALES TAX FOR WYONMING< TEXT UNCLE MARK
## TODO: how to handle errors in case part of a script fails? perhaps if there is a failure, have the script circle back to the last input and re run form there?
## TODO: see if the Digital ocean firewall rules i have set up can be replicated on ufw (or other) (that wa don't necessarily need to use digital ocean, this service can be agnostic to any ubuntu server)
## TODO: allow people to also create new project (first auto-create whichever barebones template for the framework, then commit to git. at the end need to provide instrucitons to clone the project locally...), also prompts to install db? what about existing porjects do db migrations need to be run?
## TODO: could also add ability to run this locally 
## TODO: add support for static sites! (see netlify billing fiasco)
## TODO: for gunicorn programtically get number of cpus asnd freate gunicorn isntances based on that (cpu * 2)
## have a cool thing like once in the terminal "CommandDeploy" in cool font when initially running the command
## definitely just do bash or whatever to run it automatically odn't make them then run the script locally
## create my own command that people can later access to modify things ("redploy runs set of commands tec")

## LAUNCH PLAN: Once script is done, make it downloadable (immediatly executable w | bash) from flask route (see chatgpt) already answered), create basic landing page, inspo from shipfa.st (look at bookmared articelfrom him how to launch), create stripe chekcout page
    ## - upon successful payment, send email to person with pre command instructions (below), the structure of the command (some curl thing using commanddeploy website + code as parameter), and with special access code (store code, emails/transactions in db)
    ## Trustpilot/capterra review prompt?
    ## - instructions for before executing command, thus far:
        ## - DNS
        ## - Github app token
        ## anything else?
    ##perhaps link to tutorials for setting up droplet, hetzner anything else
    ## allow people to become part of discord if they purchase rpemium tier. on one hand want more poele in discord bc it's super easy to launch new products there, but need something that creates diffference in the price poitns os that one seems "cheaper"
    
    ## Dm indie hackers for pre-launch advice, maybe do a pre-release? Maybe they can promo it and get kickback from special code? or is that too cringy?
    ## see twitter bookarmk mar clou launch form i think r/side-project on reddit, john rush how he launche dhis proejcts (bookmarked post)
    ## launch on product hunt, reddit (think of all possible forums), hacker news (post, not launch HN), developer facebook groups (geo/general), discord groups, maybe digital ocean promo (don't put too much effort into this)
    ##use netlify billing fiasco as marketing material. reach out to that guy and give him script for free in exchange for a review on the site
    ## reach out to all the people that commented on the post directly on reddit $99 you get it for a lifetime...

## Benefits; Frameowrk agnostic no matter which you choose, you can use Command Deploy to deploy all of them. ONe purchase is a lifetime of deployment...
## benefits: most of the benefits of replit without the lock in (spending time coding, not on setup/deployment). With teplit you're forced to either keep paying excalting prices and use the infra they decide, or bootstrap the setup your self. The rediculous costs and limits on replit made me decide to try and do it myself. it took sesveral weeks to get everyhting in this script set up, and now I'm sharing it wither others to use
## premium: get a url automatially for your project (if you don't have one already) before you've even bought a domain (lifetime access) ala kitj.repl.co - wildsquirrel.kitzj.c-deploy.com or cldeploy.com (two scripts one with premium features when curl) (need to set up deeper ssl certificate). Since theyare using their own servers they just have to creat the record themselves on their VPS, perahps before hand i prompt them to think of a name they want to use if not their own domain, bash script will check availability and prompt reentry until one is available
## premium: create another script that when someone wants to change their domain from my preconfigured one they can delte this domain
## premium: perhaps eventually add replit code completion model...
## preimium initial, initial dns for your site, discord group, analytics

# Prompt for Website Name
echo "What framework are you using (visit https://commanddeploy.com/frameworks for list of supported frameworks)"
read framework
framework=$(echo "$framework" | tr '[:upper:]' '[:lower:]')

echo "Enter folder name you want for the application:"
read folder_name
folder_name=$(echo "$folder_name" | tr '[:upper:]' '[:lower:]')


build_commands=""
server_start_command=""
# Update and upgrade the server
sudo apt update -y 
sudo apt-get -y install expect

spawn sudo apt upgrade -y
expect "Newer kernel available"
send "\r"

expect "Which services should be restarted?"
send "\r"

expect eof


spawn sudo apt install -y nginx 
expect "Newer kernel available"
send "\r"

expect "Which services should be restarted?"
send "\r"

expect eof

sudo apt install -y npm

echo "FRAMEWORK $framework"

if [[ $framework == "react" ]]; then
    echo "Installing dependencies for React..."
    # Install required packages
    sudo apt install -y nodejs npm


    build_commands="npm install
    npm run build
    pm2 restart main --update-env"

    server_start_command="npm start"

elif [[ $framework == "express" ]]; then
    echo "Installing dependencies for Express..."
    # Install required packages
    sudo apt install -y nodejs npm

    build_commands="npm install
    pm2 restart main --update-env"

    server_start_command="npm start"


elif [[ $framework == "vuejs" ]]; then
    echo "Installing dependencies for Vue.js..."
    # Install required packages
    sudo apt install -y nodejs npm
    npm install -g @vue/cli

    build_commands="npm install
    npm run build
    pm2 restart main --update-env"

    server_start_command="npm start"


elif [[ $framework == "flask" ]]; then
    echo "Installing dependencies for Flask..."
    # Install required packages
    # sudo apt install -y python3 python3-pip
    # sudo apt install python3-flask
    # sudo apt install python3-gunicorn
    sudo apt update -y
    sudo apt install -y python3-pip python3-dev build-essential libssl-dev libffi-dev python3-setuptools

    # set up venv
    sudo apt install python3-venv

    mkdir ~/$folder_name
    cd ~/$folder_name

    python3 -m venv venv
    source venv/bin/activate

    pip install wheel

    pip install gunicorn flask


    # cd $folder_name

    # Write the Python code to the file
    # Write the Python code to the file
    cat > app.py << EOF
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "<h1 style='color:blue'>Hello There!</h1>"

if __name__ == "__main__":
    app.run(host='0.0.0.0')
EOF

    cat > wsgi.py << EOF
from app import app

if __name__ == "__main__":
    app.run()
EOF
    # gunicorn --bind 0.0.0.0:3000 app:app

    deactivate


    ## TODO: figure out number of cpus and create number of workers accordingly
    cd /etc/systemd/system
    cat > $folder_name.service << EOF
    [Unit]
    Description=Gunicorn instance to serve $folder_name
    After=network.target

    [Service]
    User=root
    Group=www-data
    WorkingDirectory=/root/$folder_name
    Environment="PATH=/root/$folder_name/venv/bin"
    ExecStart=/root/$folder_name/venv/bin/gunicorn --workers 3 --bind unix:$folder_name.sock -m 007 wsgi:app

    [Install]
    WantedBy=multi-user.target
EOF

    cat > hellorr.service << EOF
    [Unit]
    Description=Gunicorn instance to serve hellorr
    After=network.target

    [Service]
    User=root
    Group=www-data
    WorkingDirectory=/root/hellorr
    Environment="PATH=/root/hellorr/venv/bin"
    ExecStart=/root/hellorr/venv/bin/gunicorn --workers 3 --bind unix:hellorr.sock -m 007 wsgi:app

    [Install]
    WantedBy=multi-user.target
EOF

#     ## TODO: figure out number of cpus and create number of workers accordingly
#     cd /etc/systemd/system
#     cat > helloh.service << EOF
#     [Unit]
#     Description=Gunicorn instance to serve helloh
#     After=network.target

#     [Service]
#     User=root
#     Group=www-data
#     WorkingDirectory=/root/helloh
#     Environment="PATH=/root/helloh/venv/bin"
#     ExecStart=/root/helloh/venv/bin/gunicorn --workers 3 --bind unix:/var/run/helloh.sock -m 007 wsgi:app

#     [Install]
#     WantedBy=multi-user.target
# EOF

    cd
    cd $folder_name

 
    # mkdir /var/run/$folder_name
    # chown www-data:www-data /var/run/$folder_name

    sudo systemctl daemon-reload

    sudo systemctl restart $folder_name
    sudo systemctl enable $folder_name

    sudo systemctl status $folder_name

    echo "FINISHED WITH FLASK"

    ## TODO: GET INPUT FOR "app"
    # gunicorn --bind 0.0.0.0:3000 myapp:app

    build_commands="pip install -r requirements.txt
    sudo systemctl restart gunicorn"

    server_start_command="export FLASK_RUN_PORT=3000
    flask run"

elif [[ $framework == "django" ]]; then
    echo "Installing dependencies for Django..."
    # Install required packages
    sudo apt install -y python3 python3-pip
    sudo apt install python3-django
    sudo apt install python3-gunicorn

    ## TODO: GET INPUT FOR "app"
    gunicorn --bind 0.0.0.0:3000 myapp:app

    build_commands="pip install -r requirements.txt
    python manage.py collectstatic --no-input
    sudo systemctl restart gunicorn"

    server_start_command="python manage.py runserver 0.0.0.0:3000"

elif [[ $framework == "asp" ]]; then
    echo "Installing dependencies for ASP.NET Core..."
    # Install required packages
    wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y apt-transport-https && \
    sudo apt-get update && \
    sudo apt-get install -y dotnet-sdk-6.0


    ## TODO: GET ARG TO FOLDER & Applicaiton pool name - WAIT AFTER GITHUB AND USE THAT?
    build_commands="# Build the project
    dotnet build

    # Publish the project for deployment
    dotnet publish -c Release -o /path/to/publish-folder
    
    Restart-WebAppPool -Name YourApplicationPoolName"

    server_start_command="dotnet run --urls=http://localhost:3000"

elif [[ $framework == "rails" ]]; then
    echo "Installing dependencies for Ruby on Rails..."
    # Install required packages
    sudo apt install -y curl gnupg
    curl -sSL https://get.rvm.io | bash -s stable --ruby
    source ~/.rvm/scripts/rvm
    rvm install 3.0.0
    rvm use 3.0.0 --default
    sudo apt install -y nodejs npm
    npm install -g yarn
    gem install rails
    bundle exec puma -b tcp://0.0.0.0:3000


    build_commands="# Install dependencies
    bundle install

    # Precompile assets
    bundle exec rake assets:precompile
    
    sudo systemctl restart puma"

    server_start_command="rails server -p 3000"

elif [[ $framework == "nextjs" ]]; then
    echo "Installing dependencies for Next.js..."
    # Install required packages
    sudo apt install -y nodejs npm

    build_commands="# Install dependencies
    npm install

    # Build for production
    npm run build
    
    pm2 restart main --update-env"

    server_start_command="npm start"


elif [[ $framework == "gatsby" ]]; then
    echo "Installing dependencies for Gatsby..."
    # Install required packages
    sudo apt install -y nodejs npm
    npm install -g gatsby-cli

    build_commands="# Install dependencies
    npm install

    # Build for production
    npm run build
    
    pm2 restart main --update-env"

    server_start_command="npm start"


elif [[ $framework == "laravel" ]]; then
    echo "Installing dependencies for Laravel..."
    # Install required packages
    sudo apt install -y php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath
    composer global require laravel/installer

    build_commands="# Install dependencies
    composer install

    # Optimize for production (optional)
    php artisan optimize
    
    sudo systemctl restart php-fpm"

    server_start_command="php artisan serve --port=3000"

elif [[ $framework == "symfony" ]]; then
    echo "Installing dependencies for Symfony..."
    # Install required packages
    sudo apt install -y php php-cli php-fpm php-json php-common php-xml php-mysql php-curl php-gd
    composer global require symfony/cli

    build_commands="# Install dependencies
    composer install

    # Clear the cache (if necessary)
    php bin/console cache:clear --env=prod
    
    sudo systemctl restart php-fpm"

    server_start_command="symfony server:start --port=3000"

elif [[ $framework == "angular" ]]; then
    echo "Installing dependencies for Angular..."
    # Install required packages
    sudo apt install -y nodejs npm

    build_commands="# Install dependencies
    npm install

    # Build for production
    ng build --prod
    
    pm2 restart main --update-env"

    server_start_command="npm start"


elif [[ $framework == "angularjs" ]]; then
    echo "Installing dependencies for Angular..."
    # Install required packages
    sudo apt install -y nodejs npm

    build_commands="# Install dependencies
    npm install

    # Build for production (if using a build tool like Grunt or Gulp)
    grunt build
    gulp build
    
    pm2 restart main --update-env"

    server_start_command="npm start"


elif [[ $framework == "svelte" ]]; then
    echo "Installing dependencies for Svelte..."
    # Install required packages
    sudo apt install -y nodejs npm

    build_commands="# Install dependencies
    npm install

    # Build for production
    npm run build
    
    pm2 restart main --update-env"

    server_start_command="npm start"
fi



echo "FOLDER NAME $folder_name"
CONF_PATH="/etc/nginx/sites-available/$folder_name"
echo CONF_PATH

echo "Please enter your website URL (leave out https://www):"
read website_name
website_name=$(echo "$website_name" | tr '[:upper:]' '[:lower:]')

# sudo nano /etc/nginx/sites-available/$folder_name


## TODO: Conditionally add below for php and see for other frameworks what needs to be added to nginx config file

    # location / {
    #     index index.php index.html index.htm;
    #     try_files $uri $uri/ /index.php?$query_string;
    # }

    # location ~ \.php$ {
    #     include snippets/fastcgi-php.conf;
    #     fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;  # Adjust version if needed
    #     fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    #     include fastcgi_params;
    # }


## TODO: see if anything to add/update about server file.
# Check if the Nginx configuration file already exists
if [ ! -f "$CONF_PATH" ]; then
    # Creating Nginx configuration
    sudo bash -c "cat > $CONF_PATH << EOF
server {
    listen 80;
    server_name $website_name www.$website_name;
    
    location / {
        #for node.js
        #proxy_pass http://localhost:3000;

        ## for flask (and django?)
        include proxy_params;
        proxy_pass http://unix:/root/$folder_name/$folder_name.sock;

        # proxy_http_version 1.1;
        # proxy_set_header Upgrade \$http_upgrade;
        # proxy_set_header Connection 'upgrade';
        # proxy_set_header Host \$host;
        # proxy_cache_bypass \$http_upgrade;
        # proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        # proxy_set_header X-Forwarded-Proto \$scheme;
        # proxy_set_header X-Forwarded-Host \$host;
    }

    # location /webhook {
    #     proxy_pass http://localhost:3001;
    #     proxy_http_version 1.1;
    #     proxy_set_header Upgrade \$http_upgrade;
    #     proxy_set_header Connection 'upgrade';
    #     proxy_set_header Host \$host;
    #     proxy_cache_bypass \$http_upgrade;
    #     proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    #     proxy_set_header X-Forwarded-Proto \$scheme;
    # }
}
EOF"
else
    echo "$CONF_PATH already exists."
fi


sudo ln -s /etc/nginx/sites-available/$folder_name /etc/nginx/sites-enabled/
sudo nginx -t
sudo service nginx restart

# Prompt for Email (let's encrypt)
echo "Please enter your email:"
read email

sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d $website_name -d www.$website_name
sudo systemctl status certbot.timer
sudo certbot renew --dry-run


# Prompt the user to input their GitHub username
read -p "Enter the url to your GitHub repo: " repo_url

# Extract the GitHub username and repository name from the URL
username=$(echo "$repo_url" | sed 's/.*github.com\/\([^/]*\)\/.*/\1/')
repository=$(echo "$repo_url" | sed 's/.*github.com\/[^/]*\/\([^/]*\).*/\1/')

# Prompt the user to input their GitHub personal access token
read -sp "Enter your GitHub personal access token: " token


echo ""

# Check if an SSH key pair already exists
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -C "$username"
fi

# Add the SSH key to the SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Upload the SSH public key to GitHub using the GitHub API
echo "Adding SSH key to GitHub..."
ssh_key=$(cat ~/.ssh/id_rsa.pub)
curl -H "Authorization: token $token" -X POST -d "{\"title\":\"$(hostname)\",\"key\":\"$ssh_key\"}" https://api.github.com/user/keys

echo "Cloning GitHub repo to server..."

cd /var/www

mkdir $folder_name

git clone https://github.com/$username/$repository.git

echo "Setting up GitHub Webhook..."

ip_address = curl ifconfig.me

webhook_url = "http://$ip_address/webhook"
# Create a webhook payload

## TODO: Add github secret to webhook creation

## TODO: Figure out a way to put secret in env variables not hardcoded
GITHUB_SECRET = "asdfsas324g345dg234sdf1"

## TODO: since there is potentially sensitive information passed in this script, after it finsihes running is there a way to make it self-clearing of everything?

payload=$(cat <<EOF
{
  "name": "web",
  "active": true,
  "events": [
    "push",
    "pull_request"
  ],
  "config": {
    "url": "$webhook_url",
    "content_type": "json",
    "secret": "your_webhook_secret"
  }
}
EOF
)

# Create the webhook using the GitHub API
response=$(curl -s -X POST \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $token" \
    -d "$payload" \
    "https://api.github.com/repos/$username/$repository/hooks")

# Check if the webhook was successfully created
if [[ $(echo "$response" | jq -r '.id') ]]; then
    echo "Webhook created successfully."
else
    echo "Failed to create webhook. Error message: $(echo "$response" | jq -r '.message')"
fi


echo "Setting up webhook deploy script..."

## TODO: See if for each frameworks server if can log to continuous output or just use logfile
## TODO: Can I get email working upon successful deploy? Nodemailer w perosnal email?
## DO a couple pass thorughs to make sure everything is right, try out with respective frameworks

mkdir deploy
cd deploy

sudo bash -c "cat > commands.sh << EOF

#!/bin/bash

> /var/www/logs/logfile.log
> /root/.pm2/logs/main-out.log
> /root/.pm2/logs/main-error.log
# Navigate to your project directory.
cd /var/www/$folder_name

# Pull the latest changes!
log 'Running as user: $(whoami)'
ssh -T git@github.com >> /var/www/logs/logfile.log 2>&1

echo 'Starting git pull' >> /var/www/logs/logfile.log
git pull origin main >> /var/www/logs/logfile.log 2>&1
echo 'Finished git pull' >> /var/www/logs/logfile.log

$build_commands


pm2 restart github-webhook-server --update-env
EOF"

npm install dotenv express body-parser child_process crypto

sudo bash -c "cat > webhook.js << EOF
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const crypto = require('crypto');

const app = express();
const PORT = 3001;

app.use(bodyParser.json());

app.post('/webhook', async (req, res) => {
  const GITHUB_SECRET = $GITHUB_SECRET; // Replace with your GitHub secret

  const payload = JSON.stringify(req.body);

  if (!payload) {
    return res.sendStatus(400);
  }

  const proceed = await DNS();

  if (!proceed) {
    return res.sendStatus(400);
  }

  const sig = req.headers['x-hub-signature-256'] || ""; // GitHub uses 'x-hub-signature-256' for its SHA256 payload signature header
  const hmac = crypto.createHmac('sha256', GITHUB_SECRET);
  const digest = 'sha256=' + hmac.update(payload).digest('hex');

  if (sig !== digest) {
    return res.sendStatus(403); /// Forbidden, the signatures don't match
  }

  exec(
    '/var/www/$folder_name/deploy/commands.sh >> /var/www/logs/logfile.log 2>&1',
    async (error, stdout, stderr) => {
      if (error) {
        console.error(\`exec error: \${error}\`);
        return;
      }
      console.log(\`stdout: \${stdout}\`);
      console.error(\`stderr: \${stderr}\`);
    }
  );

  res.status(200).send('Received');
});

app.listen(PORT, () => {
  console.log(`Webhook server is listening on port \${PORT}`);
});
EOF"

$build_commands
$server_start_command

## TODO: If node.js application, run main for pm2. still pm2 needed regardless for webhook
sudo npm install -g pm2
cd /var/www/$folder_name
pm2 start npm --name "main" -- start

pm2 start npm --name "github-webhook-server" -- start -- --port=3001
pm2 startup
pm2 save

echo "Your website is now live at https://$website_name"