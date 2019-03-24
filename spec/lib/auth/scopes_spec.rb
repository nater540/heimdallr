module Heimdallr
  module Auth
    describe Scopes do

      describe '.from_string' do
        subject { Scopes.from_string('users:view users:modify') }

        it { expect(subject).to be_a(Scopes) }

        describe '#all' do
          it 'is an array with two entries' do
            expect(subject.all.size).to eq(2)
          end

          it 'includes the scopes `users:view` & `users:modify`' do
            expect(subject.all).to include('users:view').and include('users:modify')
          end
        end
      end

      describe '.from_array' do
        subject { Scopes.from_array(%w[users:view users:create users:modify employees:all]) }

        it { expect(subject).to be_a(Scopes) }

        describe '#all' do
          it 'is an array with four entries' do
            expect(subject.all.size).to eq(4)
          end

          it 'includes the scopes `users:create` & `employees:all`' do
            expect(subject.all).to include('users:create').and include('employees:all')
          end
        end
      end

      describe '#exists?' do
        before do
          subject.add('users:view')
        end

        it 'returns true if a specific scope exists' do
          expect(subject.exists?('users:view')).to be_truthy
        end

        it 'returns false if a specific scope does not exist' do
          expect(subject.exists?('users:delete')).to be_falsey
        end
      end

      describe '#add' do
        it 'allows you to add a scope as a string' do
          subject.add('users:delete')
          expect(subject.all).to eq(['users:delete'])
        end

        it 'does not add duplicate scopes' do
          subject.add('users:create', 'users:delete')
          subject.add('users:delete')
          expect(subject.all).to eq(%w[users:create users:delete])
        end
      end
    end
  end
end
