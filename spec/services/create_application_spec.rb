module Heimdallr
  describe CreateApplication do
    context 'using the HMAC256 algorithm' do
      subject do
        CreateApplication.new(
          name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
          scopes: 'users:create users:update tokens:delete universe:implode',
          algorithm: 'HS256'
        ).call
      end

      it 'generates a secret value' do
        expect(subject.secret).to be_a(String)
      end

      it 'generates a key' do
        expect(subject.key).to be_a(String)
      end

      it 'does NOT generate a certificate' do
        expect(subject.certificate).to be_nil
      end
    end

    context 'using RSA256 algorithm' do
      subject do
        CreateApplication.new(
          name: "#{Faker::Superhero.prefix} #{Faker::Superhero.name} #{Faker::Superhero.suffix}",
          scopes: 'users:create users:update tokens:delete universe:implode',
          algorithm: 'RS256'
        ).call
      end

      it 'generates a secret' do
        expect(subject.secret).to be_a(String)
      end

      it 'generates a key' do
        expect(subject.key).to be_a(String)
      end

      it 'generates a certificate' do
        expect(subject.certificate).to be_a(String)
      end
    end
  end
end
