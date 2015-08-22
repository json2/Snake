function border(){
    [System.Console]::Title = "Snake - v1.0"
    [System.Console]::BackgroundColor = $global:backgroundColor
    [System.Console]::WindowHeight = 40
    [System.Console]::WindowWidth = 80
    [System.Console]::CursorVisible = $false
    $global:windowHeight = [System.Console]::WindowHeight
    $global:windowWidth = [System.Console]::WindowWidth
    $offsetTop = 1
    $offsetLeft = 1
    $offsetRight = 2
    $offsetBottom = 4
    $global:topLeft = @{ x = $offsetLeft; y = $offsetTop}
    $global:topRight = @{ x = $windowWidth - $offsetRight; y = $offsetTop}
    $global:bottomLeft = @{ x = $offsetLeft; y = $windowHeight - $offsetBottom}
    $global:bottomRight = @{ x = $windowWidth - $offsetRight; y = $windowHeight - $offsetBottom}

    clear
    $widthStr = ""
    
    for($i = 2; $i -lt $global:windowWidth; $i++){
        $widthStr += "-"
    }

    #draw vertical lines
    for($i = 1; $i -lt $global:windowHeight-$offsetRight; $i++){
        [System.Console]::SetCursorPosition(0,$i)
        Write-Host "|" -NoNewline -ForegroundColor Cyan -BackgroundColor $global:backgroundColor
        [System.Console]::SetCursorPosition($global:windowWidth-1,$i)
        Write-Host "|" -NoNewline -ForegroundColor Cyan -BackgroundColor $global:backgroundColor
    }    

    #draw horizontal lines and corners
    [System.Console]::SetCursorPosition(0,0)
    Write-Host "+" -NoNewline -ForegroundColor Cyan -BackgroundColor $global:backgroundColor
    Write-Host $widthStr -NoNewline -ForegroundColor Cyan -BackgroundColor $global:backgroundColor
    Write-Host "+" -NoNewline -ForegroundColor Cyan -BackgroundColor $global:backgroundColor
    [System.Console]::SetCursorPosition(0,$global:windowHeight-3)
    Write-Host "+" -NoNewline -ForegroundColor Cyan -BackgroundColor $global:backgroundColor
    Write-Host $widthStr -NoNewline -ForegroundColor Cyan -BackgroundColor $global:backgroundColor
    Write-Host "+" -NoNewline -ForegroundColor Cyan -BackgroundColor $global:backgroundColor
}

function frame(){   
    [System.Console]::SetCursorPosition($global:topLeft.x, $global:topLeft.y) #top left
    Write-Host " " -NoNewline -BackgroundColor DarkRed
    [System.Console]::SetCursorPosition($global:topRight.x, $global:topRight.y) #top right
    Write-Host " " -NoNewline -BackgroundColor DarkRed
    [System.Console]::SetCursorPosition($global:bottomLeft.x, $global:bottomRight.y) #bottom left
    Write-Host " " -NoNewline -BackgroundColor DarkRed
    [System.Console]::SetCursorPosition($global:bottomRight.x, $global:bottomRight.y) #bottom right
    Write-Host " " -NoNewline -BackgroundColor DarkRed
    [System.Console]::SetCursorPosition(0, $global:windowHeight-1)
}

function dot(){
    param(
        [Parameter(Mandatory=$true,
        HelpMessage = "Enter an 'x' value within the border")]
        [ValidateScript({$_ -ge $global:topLeft.x -and $_ -le $global:topRight.x})]
        [int]$x,
         
        [Parameter(Mandatory=$true,
        HelpMessage = "Enter a 'y' value within the border.")]
        [ValidateScript({$_ -ge $global:topLeft.y -and $_ -le $global:bottomLeft.y})]
        [int]$y, 
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Black", "Blue", "Cyan", "DarkBlue", "DarkCyan", "DarkGray", "DarkGreen", "DarkMagenta", 
        "DarkRed", "DarkYellow","Gray", "Green", "Magenta", "Red", "White", "Yellow")]
        [string]$color = "Green"
    )

    process{
        [System.Console]::SetCursorPosition($x, $y)
        Write-Host " " -NoNewline -BackgroundColor $color
        resetCursor
    }
}

function resetCursor(){
    param(
        [Parameter(Mandatory=$false)]
        [switch]$clearLine
    )
    [System.Console]::SetCursorPosition(0, $windowHeight-2)
    if($clearLine){
        $str = ""
        1..$global:windowWidth | % {
            $str += " "
        }
        Write-Host $str -NoNewline
        [System.Console]::SetCursorPosition(0, $windowHeight-2)
    }
}

# returns true if there is a collision, false otherwise
function collision(){
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_ -ge $global:topLeft.x -and $_ -le $global:topRight.x})]
        [int]$x,
         
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_ -ge $global:topLeft.y -and $_ -le $global:bottomLeft.y})]
        [int]$y
    )
    $global:snake | % {
        if($_.x -eq $x -and $_.y -eq $y){
            return $true
        }
    }
    return $false
}

function randomDot(){
    [int]$x = $y = $null
    do{
        $x = (Get-Random -Minimum $global:topLeft.x -Maximum ($global:topRight.x + 1))
        $y = (Get-Random -Minimum $global:topLeft.y -Maximum ($global:bottomLeft.y + 1))
    } while((collision $x $y) -or ($global:foodX -eq $x -and $global:foodY -eq $y))
    
    $global:foodX = $x
    $global:foodY = $y
    dot $global:foodX $global:foodY $global:foodColor
}

function isFood(){
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_ -ge $global:topLeft.x -and $_ -le $global:topRight.x})]
        [int]$x,
         
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_ -ge $global:topLeft.y -and $_ -le $global:bottomLeft.y})]
        [int]$y
    )
    if($x -eq $global:foodX -and $y -eq $global:foodY){
        $global:foodCount++
        return $true
    }
    return $false
}

function updateTail(){
    dot $global:snake[0].x $global:snake[0].y $global:backgroundColor
    $global:snake.RemoveAt(0)
}

function gameOver(){
    [System.Console]::SetCursorPosition([int](($global:topRight.x - $global:topLeft.x)/2) - 5, $windowHeight-2)
    Write-Host "Game Over" -ForegroundColor Red
    Write-Host "Would you like to play again? (Y/N):" -NoNewline -ForegroundColor Cyan
    do{
        $response = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if($response.character -eq 'y'){
            return $true
        }
        elseif($response.character -eq 'n'){
            #Write-Host "returning false"
            return $false
        }
    } while($true)
}

function difficulty(){ 
    Write-Host "Choose Difficulty from 1 (slowest) through 5 (fastest):" -NoNewline -ForegroundColor Cyan
    $milliseconds = 0
    do{
        $response = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if($response.character -eq '1'){
            $milliseconds = 150
        }
        elseif($response.character -eq '2'){
            $milliseconds = 100
        }
        elseif($response.character -eq '3'){
            $milliseconds = 75
        }
        elseif($response.character -eq '4'){
            $milliseconds = 50
        }
        elseif($response.character -eq '5'){
            $milliseconds = 40
        }
    } while($milliseconds -eq 0)
    resetCursor -clearLine
    return $milliseconds
}

function startGame(){
    [string]$global:backgroundColor = "DarkBlue"
    border
    [string]$global:foodColor = "Gray"
    [int]$global:foodX = $null
    [int]$global:foodY = $null
    [int]$global:foodCount = 0
    [int]$x = [int](($global:topRight.x - $global:topLeft.x)/2)
    [int]$y = [int](($global:bottomLeft.y - $global:topLeft.y)/2)
    [string]$lastKey = ""
    [string]$lastMove = ""
    $global:snake = New-Object System.Collections.Generic.List[PSObject]
    $global:snake.Add([psobject] @{
        x = $x
        y = $y
    })

    dot $x $y
    $milliseconds = difficulty 
    $time = (Get-Date).AddMilliseconds($milliseconds)
    
    Write-Host "Use arrow keys or W-A-S-D to move. Move in any direction to start..." -NoNewline
    while($true){
        $capture = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if($capture.character -eq 'w' -or $capture.virtualkeycode -eq 38){
            $lastKey = 'w'
            break
        }
        elseif($capture.character -eq 'a' -or $capture.virtualkeycode -eq 37){
            $lastKey = 'a'
            break
        }
        elseif($capture.character -eq 's' -or $capture.virtualkeycode -eq 40){
            $lastKey = 's'
            break
        }
        elseif($capture.character -eq 'd' -or $capture.virtualkeycode -eq 39){
            $lastKey = 'd'
            break
        }
    }
    resetCursor -clearLine

    randomDot

    while($true){
        if((Get-Date).CompareTo($time) -eq 1){
            try{
                if($lastKey -eq 'w'){
                    if(collision $x ($y - 1)){
                        return gameOver
                    }
                    elseif(isFood $x ($y - 1)){
                        randomDot
                    }
                    else{
                        updateTail
                    }
                    $y--
                    $lastMove = "w"
                }
                elseif($lastKey -eq 'a'){
                    if(collision ($x - 1) $y){
                        return gameOver
                    }
                    elseif(isFood ($x - 1) $y){
                        randomDot
                    }
                    else{
                        updateTail
                    }
                    $x--
                    $lastMove = "a"
                }
                elseif($lastKey -eq 's'){
                    if(collision $x ($y + 1)){
                        return gameOver
                    }
                    elseif(isFood $x ($y + 1)){
                        randomDot
                    }
                    else{
                        updateTail
                    }
                    $y++
                    $lastMove = "s"
                }
                elseif($lastKey -eq 'd'){
                    if(collision ($x + 1) $y){
                        return gameOver
                    }
                    elseif(isFood ($x + 1) $y){
                        randomDot
                    }
                    else{
                        updateTail
                    }
                    $x++
                    $lastMove = "d"
                }
                else{
                    continue
                }
                $global:snake.Add([psobject] @{
                    x = $x
                    y = $y
                })
                dot $x $y
                write-Host "Score:$global:foodCount" -NoNewline
                resetCursor

                if($lastKey -eq 'a' -or $lastKey -eq 'd'){
                    $time = (Get-Date).AddMilliseconds([int]($milliseconds*63/100))
                }
                else{
                    $time = (Get-Date).AddMilliseconds($milliseconds)
                }
            } catch{
                return gameOver
            }
        }

        if([System.Console]::KeyAvailable){ #$host.UI.RawUI.KeyAvailable does not work
            $capture = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if(($capture.character -eq 'w' -or $capture.virtualkeycode -eq 38) -and $lastMove -ne 's'){
                $lastKey = 'w'
            }
            elseif(($capture.character -eq 'a' -or $capture.virtualkeycode -eq 37) -and $lastMove -ne 'd'){
                $lastKey = 'a'
            }
            elseif(($capture.character -eq 's' -or $capture.virtualkeycode -eq 40) -and $lastMove -ne 'w'){
                $lastKey = 's'
            }
            elseif(($capture.character -eq 'd' -or $capture.virtualkeycode -eq 39) -and $lastMove -ne 'a'){
                $lastKey = 'd'
            }
        }
    }
}