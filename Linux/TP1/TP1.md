# 1ere methode 

```
J'ai suprimé un device == /dev/cpu/0/.cpuid
(on le voit car dans les permission ils commence par un c---------)

ce qui est drôle c'est que sa ne m'empeche pas de me connecter a la Machine mais par contre rien n'est traduit ce qui rend clairement la VM inutilisable ^^ ( languague machine ?)
```

# 2eme methode
```
J'ai décidé de modifier le script ".bash_profile" car celui ci ce lance directement après avoir taper c'est mot de pass Utilisateur. 

Code : 
# .bash_profile

# Get the aliases and functions

trap '' 2

if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

while :
do
        echo "dommage"
done

# User specific environment and startup programs
``` 
Voila le Bash va maintenant être envahie de "dommage"
(Me suis renseiné pour le trap j'avoue x)

# 3eme methode

Juste un forkbomb, En gros sa v'as engendrais des processes qui eux meme vont en ouvrir de nouveaux faisant juste surchauffer le noyaux :
```

:(){
 :|:&
};:

```
# 4ème methode 
