COLOR="\033[1;35m"
COLOR_RST="\033[0m"

# Create main user
echo -e "${COLOR}---Adding main user...---${COLOR_RST}"

  sudo adduser databoss
  sudo adduser databoss sudo
  echo "databoss:databoss" | chpasswd

# Done making users
echo -e "${COLOR}---Finished adding main user.---${COLOR_RST}"
