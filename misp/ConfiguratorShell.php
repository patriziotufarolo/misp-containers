<?php
class ConfiguratorShell extends AppShell {

        public $uses = array('Server');

        public function main() {
                if (count($this->args) < 2) {
                        echo "You have to specify both the config option to update and the new value as arguments";
                        return;
                }

                $option = $this->args[0];
                $value = $this->args[1];

                if (($option == "MISP.baseurl") && ($this->Server->testBaseURL($value) !== true)) {
                        echo "Invalid BaseURL";
                        return;
                }

                $this->Server->serverSettingsSaveValue($option, $value);
                echo 'Option updated.', PHP_EOL;
        }
}
