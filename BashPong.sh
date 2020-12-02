#!/bin/bash
width=$(tput cols)
height=$(tput lines)
width=$((width/5))
height=$((height-3))

arrowup='[A'
arrowdown='[B'

ball_x=$((width / 2))
ball_vel_x=$((1))
ball_y=$((height / 2))
ball_vel_y=$((1))
paddle_y=$((height / 2))
paddle_vel_y=$((1))

getInput(){
    read -t 0.1 -s -n1 c
    case "$c" in
        ('w') paddle_vel_y=$((-1)) ;;
        ('s') paddle_vel_y=$((1)) ;;
        ('') paddle_vel_y=$((0)) ;;
        ($'\033')
            read -t.001 -n2 r
            case "$r" in
                ('[A') paddle_vel_y=$((-1)) ;;
                ('[B') paddle_vel_y=$((1)) ;;
            esac
    esac
}

placeBall(){
    # Hit the right hand wall
    if [ "$1" -gt $width ]; then
        ball_vel_x=$((-1))
    elif [ "$1" -lt 2 ]; then
        ball_vel_x=$((1))
    fi

    if [ "$2" -gt $height ]; then
        ball_vel_y=$((-1))
    elif [ "$2" -lt 1 ]; then
        ball_vel_y=$((1))
    fi
}

drawScene(){
    clear
    tput cup "$1" 0
    echo -e "|\n|\n|\n|"
    tput cup "$2" "$3"
    echo "o"
}

paddleStrike(){
    paddleBottom=$((paddle_y+4))
    if [ $ball_x -lt 2 ]; then
        if [ $ball_y -lt $paddle_y ]; then
            echo "game over"
            exit 0
        elif [ $ball_y -gt $paddleBottom ]; then
            echo "game over"
            exit 0
        fi
    fi
}

trap 'tput cnorm; exit' SIGINT
tput civis

while true; do
    ball_x=$((ball_x + ball_vel_x))
    ball_y=$((ball_y + ball_vel_y))
    placeBall $ball_x $ball_y
    getInput
    paddle_y=$((paddle_y + paddle_vel_y))
    drawScene $paddle_y $ball_y $ball_x
    sleep 0.01
    paddleStrike
done
