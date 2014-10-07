class User < ActiveRecord::Base
    belongs_to :referrer, :class_name => "User", :foreign_key => "referrer_id"
    has_many :referrals, :class_name => "User", :foreign_key => "referrer_id"
    
    attr_accessible :email

    validates :email, :uniqueness => true, :format => { :with => /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/i, :message => "Invalid email format." }
    validates :referral_code, :uniqueness => true

    before_create :create_referral_code
    after_create :send_welcome_email

    REFERRAL_STEPS = [
        {
            'count' => 5,
            "html" => "HERO Recovery <br>Bar",
            "class" => "two",
            "image" =>  ActionController::Base.helpers.asset_path("refer/Web-App-Thumbnail-Image-1.jpg")
        },
        {
            'count' => 15,
            "html" => "HERO Recovery <br>Bar Pack",
            #"html" => "Truman Handle<br>w/ Blade",
            "class" => "three",
            "image" => ActionController::Base.helpers.asset_path("refer/Web-App-Thumbnail-Image-2.jpg")
        },
        {
            'count' => 30,
            "html" => "HERO Recovery <br>Bar Pack + HERO Shirt",
            #"html" => "Winston<br>Shave Set",
            "class" => "four",
            "image" => ActionController::Base.helpers.asset_path("refer/Web-App-Thumbnail-Image-3.jpg")
        },
        #{
        #    'count' => 50,
        #    "html" => "One Year<br>Free Blades",
        #    "class" => "five",
        #    "image" => ActionController::Base.helpers.asset_path("refer/blade-explain@2x.png")
        #}
    ]

    private

    def create_referral_code
        referral_code = SecureRandom.hex(5)
        @collision = User.find_by_referral_code(referral_code)

        while !@collision.nil?
            referral_code = SecureRandom.hex(5)
            @collision = User.find_by_referral_code(referral_code)
        end

        self.referral_code = referral_code
    end

    def send_welcome_email
        UserMailer.delay.signup_email(self)
    end
end
