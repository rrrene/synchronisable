require 'spec_helper'

describe Team do
  describe 'synchronization' do
    let!(:remote_attrs) do
      [
        {
          :maet_id   => 'team1',
          :eman      => 'y',
          :yrtnuoc   => 'USA',
          :ytic      => 'Washington',
          :ignored_1 => 'ignored',
          :ignored_2 => 'ignored'
        },
        {
          :maet_id   => 'team2',
          :eman      => 'z',
          :yrtnuoc   => 'France',
          :ytic      => 'Paris',
          :ignored_2 => 'ignored'
        },
        {
          :eman      => 'a',
          :yrtnuoc   => 'blah',
          :ytic      => 'blah'
        }
      ]
    end

    context 'sync with no data specified' do
      subject { -> { Team.sync } }

      it { is_expected.to change { Team.count }.by(2) }
      it { is_expected.to change { Player.count }.by(4) }

      it { is_expected.to change { Synchronisable::Import.count }.by(6) }
    end

    context 'when remote id is not specified' do
      subject { Team.sync([remote_attrs.last]) }

      its(:errors) { should have(1).items }
    end

    context 'when local record does not exist' do
      subject { -> { Team.sync(remote_attrs.take(2)) } }

      it { is_expected.to change { Team.count }.by(2) }
      it { is_expected.to change { Synchronisable::Import.count }.by(2) }
    end

    context 'when local and import records exists' do
      let!(:import) do
        create(:import,
          :remote_id => 'team1',
          :synchronisable => create(:team,
            :name => 'x',
            :country => 'Russia',
            :city => 'Moscow',
          )
        )
      end

      let!(:team) { import.synchronisable }

      subject do
        -> {
          Team.sync(remote_attrs.take(2))
          team.reload
        }
      end

      it { is_expected.to change { Team.count }.by(1) }
      it { is_expected.to change { Synchronisable::Import.count }.by(1) }

      it { is_expected.to change { team.name    }.from('x').to('y') }
      it { is_expected.to change { team.country }.from('Russia').to('USA') }
      it { is_expected.to change { team.city    }.from('Moscow').to('Washington') }
    end
  end
end
