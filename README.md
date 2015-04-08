#PEEPS
## Follow all users in a github organization from the command line.

###Dependencies
1. Github account with 2-factor authorization **disabled**.
2. Python

###To Run
1. Download the repository to your computer.
2. From the command line, navigate to the peeps folder and `chmod u+x peeps.sh`.
3. Enter `sh peeps.sh` to run the script.
4. When asked to follow an organization or a team, enter `y` to follow an organization, and enter any other value to follow a team.
5. If following an organization, enter the organization's GitHub handle. If following a team, enter the team's GitHub ID.

  The GitHub ID can be found by viewing the source code of the team's GitHub page and finding the tag `<h1 class="team-title js-team-id" data-id="1234567">`. The team ID is in the `data-id` attribute.
6. That's it!

###Note
Please report any issues you experience or submit a pull request if you see an opportunity for improvement.

###Contributions
Any contributions you make to this effort are greatly appreciated : )

###License
Please see [license](https://github.com/zfisch/peeps/blob/master/LICENSE.txt)
