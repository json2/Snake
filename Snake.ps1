function border(){
    [System.Console]::Title = "Game of Snake -- version 1.0"
    [System.Console]::BackgroundColor = $global:backgroundColor
    [System.Console]::WindowHeight = 40
    [System.Console]::WindowWidth = 80
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
    } while(collision $x $y)
    #Write-Host "x: $x y: $y" -NoNewline
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
        return $true
    }
    return $false
}

function updateTail(){
    
    dot $global:snake[0].x $global:snake[0].y $global:backgroundColor
    $global:snake.RemoveAt(0)
    
    <#
    dot $global:snake[$global:tail].x $global:snake[$global:tail].y $global:backgroundColor
    $global:head = $global:tail
    if((--$global:tail) -lt 0){
        $global:tail = $global:snake.Length - 1
    }
    #>
}

function gameover(){
    Write-Host "Game Over" -ForegroundColor Red
}

function main(){
    [string]$global:backgroundColor = "DarkBlue"
    border
    [string]$global:foodColor = "Gray"
    [int]$global:foodX = $null
    [int]$global:foodY = $null
    [int]$x = [int](($global:topRight.x - $global:topLeft.x)/2)
    [int]$y = [int](($global:bottomLeft.y - $global:topLeft.y)/2)
    [string]$lastKey = ""
    [int]$global:head = 0
    [int]$global:tail = 0
    $global:snake = New-Object System.Collections.Generic.List[PSObject] #@()
    $global:snake.Add([psobject] @{
        x = $x
        y = $y
    })

    dot $x $y
    $milliseconds = 50
    $time = (Get-Date).AddMilliseconds($milliseconds)
    
    Write-Host "Press A-S-D-W To Start..." -NoNewline
    while($true){
        $capture = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if($capture.character -eq 'w'){
            $lastKey = 'w'
            break
        }
        elseif($capture.character -eq 'a'){
            $lastKey = 'a'
            break
        }
        elseif($capture.character -eq 's'){
            $lastKey = 's'
            break
        }
        elseif($capture.character -eq 'd'){
            $lastKey = 'd'
            break
        }
    }
    
    #draw first food
    randomDot

    while($true){
        if((Get-Date).CompareTo($time) -eq 1){
            try{
                if($lastKey -eq 'w'){
                    if(collision $x ($y - 1)){
                        gameover
                        return
                    }
                    elseif(isFood $x ($y - 1)){
                        randomDot
                        #break
                    }
                    else{
                        updateTail

                        #$global:snake[$global:head].x = $x
                        #$global:snake[$global:head].y = --$y
                    }
                        $global:snake.Add([psobject] @{
                            x = $x
                            y = --$y
                        })
                }
                elseif($lastKey -eq 'a'){
                    if(collision ($x - 1) $y){
                        gameover
                        return
                    }
                    if(isFood ($x - 1) $y){
                        randomDot
                        #break
                    }
                    else{
                        updateTail

                        #$global:snake[$global:head].x = --$x
                        #$global:snake[$global:head].y = $y
                    }
                        $global:snake.Add([psobject] @{
                            x = --$x
                            y = $y
                        })
                }
                elseif($lastKey -eq 's'){
                    if(collision $x ($y + 1)){
                        gameover
                        return
                    }
                    if(isFood $x ($y + 1)){
                        randomDot
                        #break
                    }
                    else{
                        updateTail

                        #$global:snake[$global:head].x = $x
                        #$global:snake[$global:head].y = ++$y
                    }
                        $global:snake.Add([psobject] @{
                            x = $x
                            y = ++$y
                        })
                }
                elseif($lastKey -eq 'd'){
                    if(collision ($x + 1) $y){
                        gameover
                        return
                    }
                    if(isFood ($x + 1) $y){
                        randomDot
                        #break
                    }
                    else{
                        updateTail

                        #$global:snake[$global:head].x = ++$x
                        #$global:snake[$global:head].y = $y
                    }
                        $global:snake.Add([psobject] @{
                            x = ++$x
                            y = $y
                        })
                }
                else{
                    continue
                }
                dot $x $y
                if($lastKey -eq 'a' -or $lastKey -eq 'd'){
                    $time = (Get-Date).AddMilliseconds([int]($milliseconds*63/100))
                }
                else{
                    $time = (Get-Date).AddMilliseconds($milliseconds)
                }
            } catch{
                #$Error
                Write-Host "#### HIT A WALL ####"
                return
            }
        }

        if([System.Console]::KeyAvailable){ #$host.UI.RawUI.KeyAvailable does not work
            $capture = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if($capture.character -eq 'w' -and $lastKey -ne 's'){
                $lastKey = 'w'
            }
            elseif($capture.character -eq 'a' -and $lastKey -ne 'd'){
                $lastKey = 'a'
            }
            elseif($capture.character -eq 's' -and $lastKey -ne 'w'){
                $lastKey = 's'
            }
            elseif($capture.character -eq 'd' -and $lastKey -ne 'a'){
                $lastKey = 'd'
            }
        }
    }
}
