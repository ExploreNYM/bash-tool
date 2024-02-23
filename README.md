## !!!DO NOT USE UNTIL BUG FIXED!!!
## !!!DO NOT USE UNTIL BUG FIXED!!!
## !!!DO NOT USE UNTIL BUG FIXED!!!
## !!!DO NOT USE UNTIL BUG FIXED!!!
## !!!DO NOT USE UNTIL BUG FIXED!!!
## !!!DO NOT USE UNTIL BUG FIXED!!!
## !!!DO NOT USE UNTIL BUG FIXED!!!
## !!!DO NOT USE UNTIL BUG FIXED!!!
## !!!DO NOT USE UNTIL BUG FIXED!!!
## !!!DO NOT USE UNTIL BUG FIXED!!!
## !!!DO NOT USE UNTIL BUG FIXED!!!
## !!!DO NOT USE UNTIL BUG FIXED!!!

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://explorenym.net">
    <img src="https://avatars.githubusercontent.com/u/133689180?s=400&u=57735708f37db2e7881d40428d2648d8d072d3d8&v=4" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">ExploreNYM Bash Scripts</h3>
  <p align="center">
    Supporting the installation and management of NYM nodes.
    <br />
    <br />
  </p>
</div>



### Table of Contents

<ol>
	
<li><a  href="#languages-available-on-the-script">Languages</a></li>

<li><a  href="#about-the-project">About The Project</a></li>

<li><a  href="#getting-started">Getting Started</a></ul>

<li><a  href="#usage">Usage</a></li>

<li><a  href="#contributing">Contributing</a></li>

<li><a  href="#license">License</a></li>

<li><a  href="#contact">Contact</a></li>

</ol>

## Languages available on the script
- English
- Português
- Yкраїнська
- Русский
- Français
<!-- ABOUT THE PROJECT -->
## About The Project

Simple bash scripts to support community with the technical side of NYM infrastucture.

This is an attempt to make it a simple process as possible for anyone no matter there experience.

If you have any issues contact details below.
<p  align="right">(<a  href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started
These scripts are only tested on ubuntu 20.04

#### Hardware Requirements

* 1 cpu core
* 0.5gb ram
* 8gb storage space
* ipv4 & ipv6 connection

## Usage

### Mixnode Tool 

 1. Open a terminal in your local computer. (mac terminal) (windows shell)
 2. Connect to your server via ssh using your username and i.p **example** below.
```sh
ssh username@i.p
```
 3. Intall git and jq on the server
 ```sh
 sudo apt install git jq
 ```
 4. Copy and paste the script below into the server.

```sh
git clone https://github.com/ExploreNYM/bash-tool ~/bash-tool && ~/bash-tool/scripts/explore-nym.sh
```
if you are using this tool after already installing manually select migrate.

<p  align="right">(<a  href="#readme-top">back to top</a>)</p> 

<!-- CONTRIBUTING -->
## Contributing

 We greatly appreciate any and all contributions to this project.
 - [Contributing with NYM](#contributing-with-nym)
 - [Contributing with translations](#contributing-with-translations)

 ### Contributing with NYM
 If coding is not your thing you can support by delegating to our nodes.

1. Indonesia:  `4sxonGjdD4vNxWUvk8x8gCB7VpZgUBV4YDLg98oB4PUP`
2. Thailand:  `B9PJBmkT1gVNM4JSmhCa59Dj5aJ7vjk5uvuN5nbJKJW7`
3. Brazil: `2KuFi7CjKVh1mQrNKhdwLjhXBhVLRktvWMg5k4WXKdrX`

 We only accept donations to our nym wallet address below.
 
`n1cvcmxmdgw39np3ft9duxj8vdfp9ktny6jtfc0r`

### Contributing with translations
**Steps to translate the script to your language:**
1. Create your own Fork of the project.

![image](https://github.com/ExploreNYM/bash-tool/assets/69059969/62993136-a439-4572-b0e6-5fea1518d734)

2. On your own Fork, edit the `.json` files inside the text folder. Add the json object with your language and **only translate the values, not the keys**. Follow the example below where pt-br was added:

![image](https://github.com/ExploreNYM/bash-tool/assets/69059969/b5b5e2da-206c-43b8-9344-f0c1800c9ea4)

3. After you have added your translations create a pull request to add it to the script:

![image](https://github.com/ExploreNYM/bash-tool/assets/69059969/4f9eecef-3aa9-4412-bd3a-e78c87fadd73)

4. After you create the pull request an automated validation script will check the integrity of the files you edited. If the test passes you're all good and your language will soon be added, If you didn't pass the automated test check the details to see what happened at which file and then correct it in order to pass the test.

#### Examples of pull requests failing:
![image](https://github.com/ExploreNYM/bash-tool/assets/69059969/c44da60d-651c-411c-84d3-66f05a3889bf)

1. Details output when there's invalid syntax on one of the json files (invalid syntax on install.json in this case):

![image](https://github.com/ExploreNYM/bash-tool/assets/69059969/4d0fe097-0968-4e5d-9223-df20b246328e)

2. Details output when there's extra or missing keys on one of the json files (extra key on install.json in this case):

![image](https://github.com/ExploreNYM/bash-tool/assets/69059969/7ab0f6c9-23b9-40c6-8ac7-f3b4d9d45b28)

3. If you have **conflicts with the base branch** you should sync your fork similar to the way you created the pull request:
![image](https://github.com/ExploreNYM/bash-tool/assets/69059969/652e8830-c325-4222-b275-dc07dcf6ec87)

4. This is what it looks like if you pass the automated tests:
![image](https://github.com/ExploreNYM/bash-tool/assets/69059969/fedae5da-fc6c-43b2-b1f4-d997b93c4215)

<p  align="right">(<a  href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<p  align="right">(<a  href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Twitter - @Pawnflake

Discord - Pawnflake

Discord - supermeia

Website - explorenym.net
