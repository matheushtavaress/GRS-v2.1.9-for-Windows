#!/bin/bash
#
#SBATCH --job-name=grs-functionnal-tests
#SBATCH --output=
#SBATCH --time=00:30:00
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --mem-per-cpu=4G
#SBATCH --account=campus

#cnes_level2

handle_test_result () {
  test_name=${1}
  test_result=${2}
  test_time=${3}

  if [[ ${test_result} == 0 ]]
  then
    echo "<testcase classname=\"${test_name}\" name=\"${test_name}\" time=\"${test_time}\"/>" >> ${docker_report}
  else
    echo "<testcase classname=\"${test_name}\" name=\"${test_name}\" time=\"${test_time}\">" >> ${docker_report}
    echo "<failure type=\"Failed\"> See log for more info. </failure>" >> ${docker_report}
    echo "</testcase>" >> ${docker_report}
    export test_failed="fail"
  fi
}

cd ${MY_JOB_WORKDIR}
SIF=$(ls *.sif)

mkdir reports
export docker_report="reports/docker-report.xml"
echo "start CI"
echo "<testsuite tests=\"5\">" >> ${docker_report}

start=$(date +%s)
singularity run $SIF grs_launcher grs2/grs/tests/docker_tests/test_1_inputs.yml
test_status=${?}
end=$(date +%s)
handle_test_result docker_test_nominal ${test_status} $((end-start))

start=$(date +%s)
./tests/ci/test-optical-single.sh ${TEST_DATA_PATH} docker_test_single_optical ${PWD} surfwater_${CI_COMMIT_TAG}.sif
test_status=${?}
end=$(date +%s)
handle_test_result docker_test_single_optical ${test_status} $((end-start))
rm -rf docker_test_single_optical

start=$(date +%s)
./tests/ci/test-occurrence-optical.sh ${TEST_DATA_PATH} docker_test_yearly_optical ${PWD} surfwater_${CI_COMMIT_TAG}.sif
test_status=${?}
end=$(date +%s)
handle_test_result docker_test_yearly_optical ${test_status} $((end-start))
rm -rf docker_test_yearly_optical

start=$(date +%s)
./tests/ci/test-occurrence-radar.sh ${TEST_DATA_PATH} docker_test_yearly_radar ${PWD} surfwater_${CI_COMMIT_TAG}.sif
test_status=${?}
end=$(date +%s)
handle_test_result docker_test_yearly_radar ${test_status} $((end-start))
rm -rf docker_test_yearly_radar

start=$(date +%s)
./tests/ci/test-watercover-duration.sh ${TEST_DATA_PATH} docker_test_cover_duration ${PWD} surfwater_${CI_COMMIT_TAG}.sif
test_status=${?}
end=$(date +%s)
handle_test_result docker_test_cover_duration ${test_status} $((end-start))
rm -rf docker_test_cover_duration

echo "</testsuite>" >> ${docker_report}

if [ -z ${test_failed+x} ]
then
  exit 0
else
  exit 1
fi
