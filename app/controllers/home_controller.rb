class HomeController < ApplicationController
  #global accesstoken variable for when the user is logged in
  $access_token = nil
  $userbooks = nil
  $usercash = 0
  $username = nil
  $books = nil
  $loginerror = nil
  $logouterror = nil
  $deleteaccounterror = nil
  $purchasebookerror = nil
  $returnbookerror = nil
  $addcasherror = nil
  $signuperror = nil

  #to do: purchase a book, return a book

  def index
  end

  def signup
    @username = params[:username]
    @password = params[:password]

    #check if username or password arent just whitespace or empty
    if @username == nil || @password == nil || @username.strip.empty? || @password.strip.empty?
      $signuperror = "Please enter a valid username and password"
      #return
      return redirect_to '/home'
    end

    response = HTTParty.post('https://ryans-bookstore.fly.dev/auth/createuser?username=' + @username + '&password=' + @password)

    if response.code == 200
      $access_token = response['accesstoken']
      $userbooks = HTTParty.get('https://ryans-bookstore.fly.dev/user/books', headers: { 'Access-Token' => $access_token })
      response = HTTParty.get('https://ryans-bookstore.fly.dev/user/getcash', headers: { 'Access-Token' => $access_token })
      $usercash = response['cash']
      $username = @username
      $books = HTTParty.get('https://ryans-bookstore.fly.dev/bookstore/books')
      $signuperror = nil
      redirect_to '/home'
    else
      @msg = response['message']
      $signuperror = @msg == "User already exists" ? "Username already taken" : "Something went wrong when trying to sign up. Please try again."
      redirect_to '/home'
    end
  end

  def login
    @username = params[:username]
    @password = params[:password]

    response = HTTParty.post('https://ryans-bookstore.fly.dev/auth/loginuser?username=' + @username + '&password=' + @password)

    if response.code == 200
      $access_token = response['accesstoken']
      $userbooks = HTTParty.get('https://ryans-bookstore.fly.dev/user/books', headers: { 'Access-Token' => $access_token })
      puts $userbooks
      response = HTTParty.get('https://ryans-bookstore.fly.dev/user/getcash', headers: { 'Access-Token' => $access_token })
      $usercash = response['cash']
      $username = @username
      $books = HTTParty.get('https://ryans-bookstore.fly.dev/bookstore/books')
      redirect_to '/home'
    else
      $usercash = 0
      $userbooks = nil
      $access_token = nil
      $username = nil
      $books = nil
      $loginerror = "Invalid username or password"
      redirect_to '/home'
    end
  end

  def logout
    response = HTTParty.post('https://ryans-bookstore.fly.dev/auth/signoutuser', headers: { 'Access-Token' => $access_token })
    if response.code == 200
      $access_token = nil
      $userbooks = nil
      $usercash = 0
      $username = nil
      $books = nil
      $logouterror = nil
      redirect_to '/home'
    else
      $logouterror = "Something went wrong when trying to log out. Please try again."
      redirect_to '/home'
    end
  end

  def deleteaccount
    response = HTTParty.delete('https://ryans-bookstore.fly.dev/auth/deleteuser', headers: { 'Access-Token' => $access_token })
    if response.code == 200
      $access_token = nil
      $userbooks = nil
      $usercash = 0
      $username = nil
      $books = nil
      redirect_to '/home'
    else
      $deleteaccounterror = "Something went wrong when trying to delete your account. Please try again."
      redirect_to '/home'
    end
  end

  def addcash
    @cash = params[:cash]
    response = HTTParty.post('https://ryans-bookstore.fly.dev/user/addcash?cashamount=' + @cash, headers: { 'Access-Token' => $access_token })
    if response.code == 200
      response = HTTParty.get('https://ryans-bookstore.fly.dev/user/getcash', headers: { 'Access-Token' => $access_token })
      $usercash = response['cash']
      redirect_to '/home'
    end
  end

  def purchasebook

    @book_id = params[:id]
    response = HTTParty.post('https://ryans-bookstore.fly.dev/user/addbook?bookId=' + @book_id, headers: { 'Access-Token' => $access_token })
    if response.code == 200
      #call userbooks endpoint to get the updated list of books
      $userbooks = HTTParty.get('https://ryans-bookstore.fly.dev/user/books', headers: { 'Access-Token' => $access_token })
      response = HTTParty.get('https://ryans-bookstore.fly.dev/user/getcash', headers: { 'Access-Token' => $access_token })
      $usercash = response['cash']
      $purchasebookerror = nil
      redirect_to '/home'
    else
      msg = response['message']
      if msg == "Insufficient funds"
        $purchasebookerror = "You don't have enough cash to purchase this book. Please add more cash to your account."
      elsif msg == "User already owns the book"
        $purchasebookerror = "You already have this book in your library. Please return it before purchasing another copy."
      else
        $purchasebookerror = "Something went wrong when trying to purchase the book. Please try again."
      end
      redirect_to '/home'
    end

  end

  def returnbook
    @book_id = params[:id]
    response = HTTParty.delete('https://ryans-bookstore.fly.dev/user/returnbook?bookId=' + @book_id, headers: { 'Access-Token' => $access_token })
    if response.code == 200
      $userbooks = HTTParty.get('https://ryans-bookstore.fly.dev/user/books', headers: { 'Access-Token' => $access_token })
      response = HTTParty.get('https://ryans-bookstore.fly.dev/user/getcash', headers: { 'Access-Token' => $access_token })
      $usercash = response['cash']
      $returnbookerror = nil
      redirect_to '/home'
    else
      $returnbookerror = "Something went wrong when trying to return the book. Please try again."
      redirect_to '/home'
    end
  end
end
